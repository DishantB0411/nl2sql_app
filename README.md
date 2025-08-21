# CXO AI Database Assistant 💬🤖

[![Python](https://img.shields.io/badge/Python-3.9%2B-blue.svg)](https://www.python.org/downloads/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.35%2B-orange.svg)](https://streamlit.io)
[![LangChain](https://img.shields.io/badge/LangChain-0.1%2B-green.svg)](https://www.langchain.com/)
[![Google Gemini](https://img.shields.io/badge/Google-Gemini-purple.svg)](https://ai.google.dev/)

An intelligent Streamlit application that allows executive-level users to ask complex, natural-language questions about a rental business database and receive instant, data-backed answers.

This project, under the repository name `VERBAFLOW-NL2SQL`, leverages the power of Google's Gemini model through the LangChain framework to create a robust Text-to-SQL agent capable of understanding user intent, generating SQL queries, executing them, and presenting the results in a human-readable format.


***

## ## Key Features

-   **Natural Language Querying**: Ask questions in plain English, just like talking to a human analyst.
-   **Text-to-SQL Conversion**: Automatically converts user questions into accurate SQL queries.
-   **Interactive UI**: A clean and user-friendly web interface built with Streamlit.
-   **Data Visualization**: Displays query results in structured tables (DataFrames) for clarity.
-   **Query Transparency**: Shows the exact SQL query generated for each question, allowing for verification.
-   **Scoped Responses**: The AI is specifically instructed to only answer questions related to the database, politely declining any off-topic queries.

***

## ## Tech Stack

-   **Backend**: Python
-   **Web Framework**: Streamlit
-   **LLM Framework**: LangChain
-   **LLM**: Google Gemini
-   **Database**: Microsoft SQL Server
-   **Environment Variables**: `python-dotenv`
-   **Database Driver**: `pyodbc`

***

## ## Repository Structure

```
/VERBAFLOW-NL2SQL/
|
|-- db/
|   |-- setup.sql               # SQL script to create database tables and schema
|   |-- check.sql               # SQL script to insert/verify sample data
|
|-- test_suite/
|   |-- test_questions.csv      # Test dataset for accuracy evaluation
|
|-- .env                      # Local file for storing environment variables (API key)
|-- .gitignore                # Specifies files for Git to ignore
|-- app.py                    # Main Streamlit application code
|-- README.md                 # Project documentation (this file)
|-- requirements.txt          # Python package dependencies
|-- testing_connection.py     # Utility script for testing the database connection
|-- testing.ipynb             # Jupyter Notebook for development and testing
|-- REPORT.md                 # System accuracy and performance report
```

***

## ## Setup and Installation Guide

Follow these steps to set up and run the project on your local machine.

### ### 1. Prerequisites

-   [Python 3.9+](https://www.python.org/downloads/)
-   [Git](https://git-scm.com/)
-   [Microsoft SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) with a running instance (e.g., `SQLEXPRESS`).
-   [Microsoft ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server).

### ### 2. Clone the Repository

Open your terminal and clone the repository:
```bash
git clone [https://github.com/](https://github.com/)<your-username>/VERBAFLOW-NL2SQL.git
cd VERBAFLOW-NL2SQL
```

### ### 3. Set Up the Python Environment

It is highly recommended to use a virtual environment.
```bash
# Create a virtual environment
python -m venv env

# Activate it
# On Windows:
env\Scripts\activate
# On macOS/Linux:
source env/bin/activate

# Install the required packages
pip install -r requirements.txt
```

### ### 4. Configure the Database

1.  **Create the Database**: Using a tool like SQL Server Management Studio (SSMS), connect to your SQL Server instance and create a new, empty database named `rental_app`.
2.  **Create Tables**: Execute the `db/setup.sql` script against the `rental_app` database to create the necessary table structures.
3.  **Populate/Verify Data**: Execute the `db/check.sql` script to populate the tables with sample data or to verify the setup.

### ### 5. Set Up Your API Key

The application requires a Google Gemini API key. This is handled using a local `.env` file.

1.  In the root of the project directory, create a file named `.env`.
2.  Add your API key to the file as shown below. The `.gitignore` file is already configured to prevent this file from being committed.

    ```
    # .env

    GEMINI_API_KEY="YOUR_API_KEY_HERE"
    ```

### ### 6. Run the Application

You're all set! Run the following command in your terminal from the project's root directory:
```bash
streamlit run app.py
```
The application will open in a new tab in your web browser.

***

## ## How to Use

Once the application is running:
1.  A chat interface will be displayed.
2.  The sidebar on the left shows the available tables and their schemas for reference.
3.  Type a question about the rental business into the input box at the bottom (e.g., "How many properties are available in London?").
4.  Press Enter. The AI assistant will process your request, generate a SQL query, and display the answer along with the data.