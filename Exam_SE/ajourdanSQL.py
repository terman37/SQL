#Imports
import os
import argparse
from argparse import RawTextHelpFormatter
import subprocess
import sys

try:
    import pandas as pd
except ImportError:
    subprocess.call([sys.executable, "-m", "pip", "install", 'pandas'])
finally:
    import pandas as pd

try:
    import pyodbc
except ImportError:
    subprocess.call([sys.executable, "-m", "pip", "install", 'pyodbc'])
finally:
    import pyodbc


class Db:
    """
    Class to simplify connection string creation to DB
    and executing queries with or without returning dataframe
    with error management at connection and execution level.
    """

    # init/construct
    def __init__(self):
        srv_name = SERVER_NAME
        db_name = DATABASE_NAME
        drv = DB_DRIVER
        self.conn_str = 'DRIVER=%s; SERVER=%s;DATABASE=%s;Trusted_Connection=yes' % (drv, srv_name, db_name)
        self.cnxn = None

    def connect_db(self):
        """
        Connect to the database using the connection string created during instantiation
        :return: nothing, but creates cnxn, a pyodbc connect object.
        """
        # try to connect to db, if exception raised print an error message and quit
        try:
            self.cnxn = pyodbc.connect(self.conn_str, timeout=3)
        except pyodbc.Error as e:
            print("\nError: Not able to connect to DataBase")
            print("Conn. String used: %s" % self.conn_str)
            print("Error returned from SQLServer: \n", e.args[1].replace(';', '\n'))
            quit()

    def execute_sql(self, str_sql, return_pd=True):
        """
        :param str_sql: string: containing SQL statement to run
        :param return_pd: Boolean
        :return: if return_pd == True return a dataframe, else return nothing
        """
        self.connect_db()
        # if asked to return a data frame, then use pandas read_sql implementation
        # instead of pyodbc cursors.
        if return_pd:
            try:
                result = pd.read_sql(str_sql, self.cnxn)
                return result
            except Exception as e:
                print("\nError: Not able to Query the DataBase")
                print("Query run: %s" % str_sql)
                print("Error description: \n", e.args[0])
                self.close_connection()
                quit()
        else:
            try:
                self.cnxn.execute(str_sql)
                self.cnxn.commit()
            except Exception as e:
                print("\nError running ALTER query")
                print("Error description: \n", e.args[1].replace(';', '\n'))
                self.close_connection()
                quit()

    def close_connection(self):
        """
        Close database connection
        :return: nothing
        """
        self.cnxn.close()


def check_survey_structure(persist_file):
    """
    This function checks if survey structure changes compared to persistent file.
    if any change or file not existing, then update vw_AllSurveyData in DB
    :param persist_file: string, filename with extension for the persistent file, Default = PERSIST_FILE
    :return: Nothing
    """
    # Initialize
    old_struct = pd.DataFrame()

    # get the current one from DataBase
    myDb = Db()
    surv_struct = myDb.execute_sql("SELECT * FROM SurveyStructure")

    # read persistent file, if read fails (file not existing), create it and consider view should be updated
    if os.path.exists(persist_file):
        try:
            old_struct = pd.read_csv(persist_file)
        except Exception as e:
            print(e)
    else:
        print("\nNew persistent file created")

    # if there is change in survey structure, generate new SQL for vw_AllSurveyData
    if not surv_struct.equals(old_struct):
        new_sql = generate_new_sql_for_view()
        # ALTER vw_AllSurveyData in DB
        alter_sql = 'CREATE OR ALTER VIEW vw_AllSurveyData AS ' + new_sql
        myDb.execute_sql(alter_sql, return_pd=False)
        # modify persistent file
        surv_struct.to_csv(persist_file, index=False)
        print("\nvw_AllSurveyData definition updated")
    else:
        print("\nNo need to update vw_AllSurveyData definition")

    myDb.close_connection()


def generate_new_sql_for_view():
    """
    Generate the SQL to retreive the pivoted survey answer data
    Equivalent to the function written in MSSQL fn_GetAllSurveyDataSQL
    :return: string: SQL Query to view pivoted datas
    """

    # template query definitions
    qry_TemplateForAnswerColumn = """COALESCE(
                                    (SELECT a.Answer_Value
                                    FROM Answer as a
                                    WHERE
                                        a.UserId = u.UserId AND a.SurveyId = <SURVEY_ID> AND a.QuestionId = <QUESTION_ID>
                                    ), -1) AS ANS_Q<QUESTION_ID> """

    qry_TemplateForNullColumn = """NULL As ANS_Q<QUESTION_ID> """

    qry_TemplateOuterUnionQuery = """SELECT u.UserId, <SURVEY_ID> as SurveyId, <DYNAMIC_QUESTION_ANSWERS> 
                                    FROM [User] as u 
                                    WHERE EXISTS( 
                                    SELECT * FROM Answer as a WHERE a.UserId=u.UserId AND a.SurveyId = <SURVEY_ID>) """

    # loop query definitions
    qry_surveys = """SELECT s.SurveyId FROM Survey AS s ORDER BY SurveyId;"""

    qry_currentQuestions = """SELECT SurveyId, QuestionId, InSurvey FROM 
                            (SELECT SurveyId, QuestionId, 1 as InSurvey 
                            FROM SurveyStructure 
                            WHERE SurveyId = @currentSurveyId 
                            UNION 
                            SELECT @currentSurveyId as SurveyId, Q.QuestionId, 0 as InSurvey 
                            FROM Question as Q 
                            WHERE NOT EXISTS 
                            (SELECT * FROM SurveyStructure as S 
                            WHERE S.SurveyId = @currentSurveyId AND S.QuestionId = Q.QuestionId)
                            ) as t ORDER BY QuestionId;"""

    myDb = Db()

    surveys = myDb.execute_sql(qry_surveys)
    finalQueryList = []

    # loop over all surveys
    for surveyid in surveys['SurveyId']:

        columnsQueryPartList = []
        qry_currentQuestionsForSurvey = qry_currentQuestions.replace('@currentSurveyId', str(surveyid))
        currentQuestions = myDb.execute_sql(qry_currentQuestionsForSurvey)

        # loop over all questions
        for idx, question in currentQuestions.iterrows():
            if question['InSurvey'] == 0:
                columnsQueryPartList.append(
                    qry_TemplateForNullColumn.replace('<QUESTION_ID>', str(question['QuestionId'])))
            else:
                columnsQueryPartList.append(
                    qry_TemplateForAnswerColumn.replace('<QUESTION_ID>', str(question['QuestionId'])))

        columnsQueryPart = ', '.join(columnsQueryPartList)

        currentUnionQueryBlock = qry_TemplateOuterUnionQuery.replace('<DYNAMIC_QUESTION_ANSWERS>', columnsQueryPart)
        currentUnionQueryBlock = currentUnionQueryBlock.replace('<SURVEY_ID>', str(surveyid))
        finalQueryList.append(currentUnionQueryBlock)

    finalQuery = 'UNION '.join(finalQueryList)
    myDb.close_connection()

    return finalQuery


def main():
    """
    Main function
    :return: Nothing
    """
    # Check if there is any change in survey structure compared with PERSIST_FILE
    check_survey_structure(PERSIST_FILE)
    # get vw_AllSurveyData from DB
    myDb = Db()
    extract = myDb.execute_sql("SELECT * FROM vw_AllSurveyData")
    # save in a CSV with correct column names
    extract.to_csv(OUTPUT_FILE, index=False)
    print('\nData extracted to %s' % OUTPUT_FILE)


if __name__ == '__main__':

    # Use arguments in case of using python from command line
    parser = argparse.ArgumentParser(description='Algorithm to get the always-fresh pivoted survey data\n'
                                                 + '> default arguments are set up for my configuration',
                                     formatter_class=RawTextHelpFormatter)
    parser.add_argument('--srvname', type=str, default='LAPTOP-NLGPTOS3', help='Name of the MSSQL server to connect to')
    parser.add_argument('--dbname', type=str, default='Survey_Sample_A19', help='Name of the database to connect to')
    parser.add_argument('--outfile', type=str, default='output.csv', help='Name of the file to output retrieved data (csv)')
    parser.add_argument('--pfile', type=str, default='persist.csv', help='Name of the file storing survey structure (csv)')
    parser.add_argument('--driver', type=str, default='{ODBC Driver 17 for SQL Server}', help='ODBC Driver for DB connection . Check pyodbc wiki')

    args = parser.parse_args()

    # GLOBAL variables
    SERVER_NAME = args.srvname
    DATABASE_NAME = args.dbname
    PERSIST_FILE = args.pfile
    DB_DRIVER = args.driver
    OUTPUT_FILE = args.outfile

    main()
