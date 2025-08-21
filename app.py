import streamlit as st
import pandas as pd
from decimal import Decimal
import datetime
from langchain_community.utilities import SQLDatabase
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.agent_toolkits import SQLDatabaseToolkit
from langchain.agents import AgentExecutor, create_react_agent
from langchain import hub
from sqlalchemy import text
import warnings
import os
from dotenv import load_dotenv
load_dotenv()
warnings.filterwarnings('ignore')

# -------------------------
# Page Configuration
# -------------------------
st.set_page_config(page_title="CXO AI Database Assistant", layout="wide")
st.title("💬Database Assistant")
st.write("Ask complex questions about the database, and I'll get the answers from our database.")

# -------------------------
# Secure API Key Handling
# -------------------------
try:
    # --- BEST PRACTICE: Load API key from st.secrets for security ---
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
except (FileNotFoundError, KeyError):
    st.error("`GEMINI_API_KEY` not found in st.secrets. Please add it to your `.streamlit/secrets.toml` file.")
    st.stop()

# -------------------------
# Caching Database Connection
# -------------------------
@st.cache_resource
def get_database_connection():
    connection_uri = (
        "mssql+pyodbc://@localhost\\SQLEXPRESS/rental_app"
        "?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
    )
    db = SQLDatabase.from_uri(connection_uri)
    return db

db = get_database_connection()

# -------------------------
# LLM and SQL Agent Setup
# -------------------------
@st.cache_resource
def get_sql_agent():
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.5-flash",
        google_api_key=GEMINI_API_KEY,
        convert_system_message_to_human=True
    )
    
    toolkit = SQLDatabaseToolkit(db=db, llm=llm)
    tools = toolkit.get_tools()
    
    prompt = hub.pull("hwchase17/react-chat") # Using a conversational prompt
    
    agent = create_react_agent(llm, tools, prompt)
    
    agent_executor = AgentExecutor(
        agent=agent,
        tools=tools,
        verbose=True,
        handle_parsing_errors=True,
        max_iterations=10,
        return_intermediate_steps=True,
    )
    
    return agent_executor

agent_executor = get_sql_agent()

# -------------------------
# Sidebar Schema Display
# -------------------------
st.sidebar.header("Database Information")
with st.sidebar.expander("View Tables", expanded=True):
    table_names = db.get_usable_table_names()
    for table in table_names:
        with st.expander(f"**{table}**"):
            try:
                columns = db._inspector.get_columns(table)
                for col in columns:
                    st.markdown(f"- `{col['name']}` ({str(col['type'])})")
            except Exception as e:
                st.error(f"Could not inspect table {table}: {e}")

# -------------------------
# Streamlit Chat UI
# -------------------------

if "messages" not in st.session_state:
    st.session_state.messages = []

for i, message in enumerate(st.session_state.messages):
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

        if "result" in message and not message["result"].empty:
            st.dataframe(message["result"])
        
        if "sql" in message and message["sql"]:
            with st.expander("🔍 View SQL Query"):
                st.code(message["sql"], language="sql")

if prompt := st.chat_input("E.g., show me properties from london"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        try:
            with st.spinner("Thinking... 🧠"):
                response = agent_executor.invoke({"input": prompt, "chat_history": st.session_state.messages})
                
                answer = response.get("output", "No answer found.")
                intermediate_steps = response.get("intermediate_steps", [])

                # --- START: NEW LOGIC TO CHECK FOR TOOL USE ---
                # If intermediate_steps is empty, the agent did not use a tool.
                # This means it answered from its general knowledge.
                if not intermediate_steps:
                    answer = "I can only answer questions related to the rental business database."
                    final_sql_query = ""
                    df = pd.DataFrame()
                # --- END: NEW LOGIC ---
                else:
                    # This is your existing logic, now in an else block
                    final_sql_query = ""
                    sql_result_object = None
                    df = pd.DataFrame()

                    for step in reversed(intermediate_steps):
                        action = step[0]
                        if action.tool == 'sql_db_query':
                            sql_result_object = step[1]
                            tool_input = action.tool_input
                            if isinstance(tool_input, dict):
                                final_sql_query = tool_input.get('query', '')
                            elif isinstance(tool_input, str):
                                final_sql_query = tool_input
                            break
                    
                    if sql_result_object is not None:
                        try:
                            if isinstance(sql_result_object, str):
                                data = eval(sql_result_object)
                            else:
                                data = sql_result_object
                            if isinstance(data, list) and data and final_sql_query:
                                with db._engine.connect() as connection:
                                    result_proxy = connection.execute(text(final_sql_query))
                                    columns = list(result_proxy.keys())
                                    df = pd.DataFrame(data, columns=columns)
                            elif not isinstance(data, list):
                                df = pd.DataFrame([{'result': data}])
                            else:
                                df = pd.DataFrame()
                        except Exception as e:
                            st.warning(f"Could not process result. Error: {e}")

                st.markdown(answer)

                if not df.empty:
                    st.dataframe(df)

                if final_sql_query:
                    with st.expander("🔍 View SQL Query"):
                        st.code(final_sql_query, language="sql")
                
                st.session_state.messages.append({
                    "role": "assistant",
                    "content": answer,
                    "result": df,
                    "sql": final_sql_query
                })

        except Exception as e:
            error_message = f"Sorry, I encountered an error: {e}"
            st.error(error_message)
            st.session_state.messages.append({"role": "assistant", "content": "Sorry, unable to answer at this point in time."})
