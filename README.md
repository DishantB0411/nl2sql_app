# Database Assistant: A Deep Dive 💬🤖

[![Python](https://img.shields.io/badge/Python-3.9%2B-blue.svg)](https://www.python.org/downloads/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.35%2B-orange.svg)](https://streamlit.io)
[![LangChain](https://img.shields.io/badge/LangChain-0.1%2B-green.svg)](https://www.langchain.com/)
[![Google Gemini](https://img.shields.io/badge/Google-Gemini-purple.svg)](https://ai.google.dev/)

## 1. Project Abstract
![UI](https://github.com/DishantB0411/nl2sql_app/blob/main/screenshots/Screenshot%202025-08-21%20225127.png)
This repository, `NL2SQL_APP`, contains the source code for the **Database Assistant**, an advanced conversational AI application. Its primary objective is to bridge the gap between complex business data and non-technical stakeholders (such as C-level executives) by providing a natural language interface for database querying.

The system leverages a Large Language Model (LLM), specifically Google's **Gemini**, integrated through the **LangChain** framework. It functions as a **Text-to-SQL agent**, interpreting user questions, dynamically generating SQL queries, executing them against a live MS SQL Server database, and returning answers in a clear, digestible format. The entire user experience is delivered through an interactive web application built with **Streamlit**.

This document provides a detailed breakdown of the project's methodology, architecture, code implementation, and the challenges overcome during its development.

***

## 2. Key Features

The application is designed with a focus on usability, transparency, and robustness.

-   **Natural Language Querying**: Ask questions in plain English, just like talking to a human analyst.
-   **Interactive Database Schema Explorer**: The sidebar provides a convenient way to view all available tables and their respective column names and data types, giving users context for their questions.

    

-   **Transparent SQL Query Display**: For every answer generated, the application includes an expandable section that reveals the exact SQL query the AI used. This builds trust and allows for technical verification of the results.

    

-   **Scoped and Safe Responses**: The agent is explicitly engineered to reject questions outside the scope of the rental business database. This was a crucial step to constrain the generalist nature of the Gemini LLM and ensure it remains a focused business tool.

    

-   **Structured Data Presentation**: Results are displayed in clean, well-formatted Pandas DataFrames for easy reading and analysis.

***

## 3. Core Methodology and System Architecture

The application operates on the **ReAct (Reason and Act)** framework, a powerful paradigm for creating autonomous agents. The agent iteratively reasons about a problem, chooses a tool (an "action"), observes the result, and repeats this loop until it arrives at a final answer.

### Architectural Flow

```
[User] -> [Streamlit Frontend] -> [Agent Executor] -> [LLM (Gemini)]
   ^                                                       | (Reasoning & Tool Selection)
   |                                                       v
   |                                                 [SQL Toolkit] -> [SQL Database]
   |                                                       | (Query Execution)
   |                                                       v
   |                                                 [Agent Executor] <- [SQL Result]
   | (Formatted Answer & DataFrame)                        | (Observation & Final Answer Generation)
   +-------------------------------------------------------+
```

1.  **User Input**: The user types a question into the Streamlit chat interface.
2.  **Agent Invocation**: The backend passes this input to the **LangChain Agent Executor**.
3.  **Reasoning Loop (LLM)**: The Agent Executor, guided by its custom prompt, asks Gemini to decide on the next step. The LLM reasons that it needs to query the database and decides to use the `sql_db_query` tool.
4.  **Action (Toolkit)**: The agent executes the chosen tool with the generated SQL query.
5.  **Execution & Observation**: The `SQLDatabaseToolkit` connects to the MS SQL Server, runs the query, and captures the result. This result is the "observation."
6.  **Final Answer Generation**: The observation is fed back to the LLM. The LLM now has the data and concludes it can answer the user's original question, formulating a natural language response.
7.  **Response to UI**: The Agent Executor returns the final answer and all intermediate steps to the Streamlit app, which then formats and displays it to the user.

***

## 4. Code Implementation: A Detailed Walkthrough

The core logic is contained within `app.py`. Below is a breakdown of its key components.

### 4.1. LLM and Agent Setup (`get_sql_agent`)

This function is the heart of the application's AI capabilities.
-   **LLM Instantiation**: `ChatGoogleGenerativeAI` is initialized.
-   **Toolkit Creation**: `SQLDatabaseToolkit` provides the agent with all necessary tools for database interaction (`sql_db_query`, `sql_db_schema`, etc.).
-   **Critical Prompt Engineering**: A specific `system_prompt` is used to strictly define the agent's role, forcing it to rely only on its tools and to decline any out-of-scope questions. This was a key step to tame the generalist nature of the Gemini model.
-   **Agent Executor**: `AgentExecutor` is the runtime that manages the entire Reason-Act loop, with `return_intermediate_steps=True` being essential for extracting the generated SQL query for display.

### 4.2. Streamlit UI and Chat Logic

-   **Sidebar for Database Info**: The code explicitly gets the table names from the `db` object and iterates through them, using `db._inspector.get_columns(table)` to fetch and display the schema for each table in the sidebar.
-   ![sidebar](https://github.com/DishantB0411/nl2sql_app/blob/main/screenshots/Screenshot%202025-08-21%20225047.png)
-   **Chat Display & SQL Extraction**: When a user submits a prompt, the app invokes the agent. It then parses the `intermediate_steps` from the response to find the final `sql_db_query` action. This provides both the raw data and the exact SQL query, which is stored and displayed in the `st.expander("🔍 View SQL Query")` component.

***

## 5. Database Schema

The `rental_app` database contains the core tables for the business. The schema is defined in `db/setup.sql`.

-   **Note on Data Volume**: For the purpose of this assignment, only a small, representative dataset has been included. The system is fully capable of scaling to handle much larger volumes of data.

*(List your actual tables here. Example below)*

-   **`users`**
-   **`favorites`**
-   **`bookings`**
-   **`properties`** 
-   **`property_photos`**
-   **`reviews`**
-   **`payments`**

***

## 6. Setup and Installation Guide

Follow these steps to set up and run the project on your local machine.

### 6.1. Prerequisites and Recommended Tooling

-   **Prerequisites**:
    -   [Python 3.9+](https://www.python.org/downloads/)
    -   [Git](https://git-scm.com/)
    -   [Microsoft SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
    -   [Microsoft ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server).
-   **Recommended Tooling**:
    -   For easier database management within VS Code, it is highly recommended to install the **MSSQL extension**. It allows you to connect to your database, run queries, and manage tables directly from your editor.
<img width="1220" height="203" alt="Screenshot 2025-08-21 231149" src="https://github.com/user-attachments/assets/b2048cd6-faaf-4e67-89e1-254a55302c0a" />


### 6.2. Installation Steps

1.  **Clone the Repository**:
    ```bash
    git clone [https://github.com/](https://github.com/)DishantB0411/nl2sql_app.git
    cd VERBAFLOW-NL2SQL
    ```
2.  **Set Up Python Environment**:
    ```bash
    python -m venv env
    # On Windows: env\Scripts\activate
    # On macOS/Linux: source env/bin/activate
    pip install -r requirements.txt
    ```
3.  **Configure the Database**:
    -   First, using a tool like SQL Server Management Studio (SSMS) or the VS Code MSSQL extension, **create a new, empty database** named `rental_app`.
    -   Then, execute the `db/setup.sql` script to create the table structures.(NOTE: For assignment purpose the data added is limited can add more data.)
    -   Finally, execute `db/check.sql` to populate the tables with sample data.

### 6.3. **IMPORTANT: Customizing the Database Connection URI**

The application needs to know how to connect to your specific database instance. This is configured via a connection URI string within the source code.

**Location**: Open the `app.py` file and locate the `get_database_connection` function.

**Code Block to Modify**:
```python
# app.py

@st.cache_resource
def get_database_connection():
    # THIS IS THE LINE YOU MAY NEED TO CHANGE
    connection_uri = (
        "mssql+pyodbc://@localhost\\SQLEXPRESS/rental_app"
        "?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
    )
    db = SQLDatabase.from_uri(connection_uri)
    return db
```

**How to Modify the `connection_uri`:**

-   **To change the Server/Instance Name**: The default is `localhost\SQLEXPRESS`. Replace this with your server's address.
    -   *Example*: If your server is just the machine name, like `MYPC`, change it to `@MYPC`.
    -   *Example*: If it's a remote server with an instance name `SQLPROD`, change it to `@remote-server-ip\SQLPROD`.

-   **To change the Database Name**: The default is `rental_app`. Replace this with the name of the database you created.
    -   *Example*: `/my_business_db`

-   **To use SQL Server Authentication** (if not using a trusted Windows connection): You must provide a username and password.
    -   *Example*: `mssql+pyodbc://your_user:your_password@localhost\\SQLEXPRESS/rental_app?driver=...`
- For the time being use this connection URI else you can add your own connection uri and check the connection using `testing_connection.py` file.
### ### 6.4. Set Up API Key

-   In the project root, create a file named `.env`.
-   Add your Gemini API key to this file:
    ```
    GEMINI_API_KEY="YOUR_API_KEY_HERE"
    ```

### 6.5. Run the Application

```bash
streamlit run app.py
```

***

## 7. Challenges and Solutions

1.  **Challenge**: The agent was answering general knowledge questions, breaking its intended scope.
    -   **Solution**: Implemented  **no-tool-using** method so that llm don't use it's general knowledge to answer any question not related to the database. The custom setting explicitly forbids this behavior and forces the agent to decline off-topic questions.
![outofbox](https://github.com/DishantB0411/nl2sql_app/blob/main/screenshots/Screenshot%202025-08-21%20225343.png)
2.  **Challenge**: The DataFrame displayed in Streamlit had integer indexes (0, 1, 2...) instead of the correct column names.
    -   **Solution**: After receiving the raw tuple data from the agent, a secondary step was added to re-execute the same query using SQLAlchemy's core engine (`db._engine`). This allowed access to the `keys()` method of the result proxy, which provides the column headers.

3.  **Challenge**: Inconsistencies between LangChain versions led to an `AttributeError` when trying to access the database engine (`db.engine`).
    -   **Solution**: Investigated the `SQLDatabase` object structure and found that the engine was stored in a protected `_engine` attribute in the current version. The code was updated to use `db._engine`, resolving the issue.

## 8. Future Improvements

While the current system is robust, there are several avenues for future enhancement:

-   **📊 Dynamic Chart Generation**: Integrate a data visualization tool (like Matplotlib or Plotly) and empower the agent to decide when to display results as a chart instead of a table.
-   **🧠 Enhanced SQL Complexity**: Improve the agent's ability to handle more complex queries, such as multi-table joins and subqueries, through advanced prompt engineering or by fine-tuning a model.
-   **⚡ Query Caching**: Implement a caching layer to store the results of frequently asked questions, which would significantly improve response times and reduce API costs.
-   **🔐 User Authentication**: Add a login system to secure the application and potentially implement role-based access to the data.
-   **✍️ Natural Language Editing**: Allow users to make follow-up corrections in natural language (e.g., "Actually, show that for Bradford instead").

***

## 9. Author

This project was created and is maintained by:

-   **[Dishant Bothra]**
    -   GitHub: [@_Horizon](https://github.com/DishantB0411)
    -   LinkedIn: [Dishant Bothra](https://www.linkedin.com/in/dishantbothra/)

***

## 10. License

This project is licensed under the MIT License. You can find the full license text in the `LICENSE` file in the repository.

© 2025, [Dishant Bothra]. All Rights Reserved.
