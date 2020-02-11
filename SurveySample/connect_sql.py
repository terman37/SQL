
# connection strings can be found on connectionstrings.com

import pandas as pd
import pyodbc

# SIMPLE QUERY TO WORLDWIDEIMPORTERS
sql_conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server}; SERVER=LAPTOP-NLGPTOS3;DATABASE=WideWorldImporters;Trusted_Connection=yes')
query = "SELECT CustomerId FROM [Sales].[Customers]"
df = pd.read_sql(query, sql_conn)
print(df.head(3))

# EXECUTE STORED PROCEDURE ON SURVEY
sql_conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server}; SERVER=LAPTOP-NLGPTOS3;DATABASE=Survey_Sample_A18;Trusted_Connection=yes')
query = "EXECUTE [dbo].[getallsurveydata] "
df = pd.read_sql(query, sql_conn)
print(df.head(3))

# IF USE OF STORED PROCEDURE IS RESTRICTED
# USE VIEW
query = "SELECT * FROM [Survey_Sample_A18].[dbo].[vw_AllSurveyData] ORDER BY SurveyId, UserId"
df = pd.read_sql(query, sql_conn)
print(df.head(3))