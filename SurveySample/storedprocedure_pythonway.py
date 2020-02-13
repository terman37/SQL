
import pandas as pd
import pyodbc
import time 

sql_conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server}; SERVER=LAPTOP-NLGPTOS3;DATABASE=Survey_Sample_A18;Trusted_Connection=yes')


### first way using same structure as in stored procedure in MSSQL

# template query definitions
t1=time.time()
qry_TemplateForAnswerColumn = 'COALESCE( ' \
				+ '(SELECT a.Answer_Value ' \
				+ 'FROM	Answer as a ' \
				+ 'WHERE a.UserId=u.UserId AND a.SurveyId= <SURVEY_ID> AND a.QuestionId= <QUESTION_ID>) ' \
				+ ', -1) As ANS_Q<QUESTION_ID> '

qry_TemplateForNullColumn = 'NULL As ANS_Q<QUESTION_ID> '

qry_TemplateOuterUnionQuery = 'SELECT u.UserId, <SURVEY_ID> as SurveyId, <DYNAMIC_QUESTION_ANSWERS> ' \
				+ 'FROM	[User] as u ' \
				+ 'WHERE EXISTS( ' \
				+ 'SELECT * FROM Answer as a WHERE a.UserId=u.UserId AND a.SurveyId = <SURVEY_ID>) '

# loop query definitions

qry_surveys = 'SELECT s.SurveyId FROM Survey AS s ORDER BY SurveyId;'

qry_currentQuestions = 'SELECT SurveyId, QuestionId, InSurvey FROM ' \
					+ '(SELECT SurveyId, QuestionId, 1 as InSurvey ' \
					+ 'FROM SurveyStructure ' \
					+ 'WHERE SurveyId = @currentSurveyId ' \
					+ 'UNION ' \
					+ 'SELECT @currentSurveyId as SurveyId, Q.QuestionId, 0 as InSurvey ' \
					+ 'FROM	Question as Q ' \
					+ 'WHERE NOT EXISTS ' \
					+ '(SELECT * FROM SurveyStructure as S ' \
					+ 'WHERE S.SurveyId = @currentSurveyId AND S.QuestionId = Q.QuestionId) ' \
					+ ') as t ORDER BY QuestionId;'

finalQueryList=[]

surveys = pd.read_sql(qry_surveys, sql_conn)
for surveyid in surveys['SurveyId']:
	
	columnsQueryPartList = []

	qry_currentQuestionsForSurvey = qry_currentQuestions.replace('@currentSurveyId',str(surveyid))
	currentQuestions = pd.read_sql(qry_currentQuestionsForSurvey, sql_conn)

	for idx,question in currentQuestions.iterrows():
		if question['InSurvey'] == 0:
			columnsQueryPartList.append(qry_TemplateForNullColumn.replace('<QUESTION_ID>',str(question['QuestionId'])))
		else:
			columnsQueryPartList.append(qry_TemplateForAnswerColumn.replace('<QUESTION_ID>',str(question['QuestionId'])))
	
	columnsQueryPart = ', '.join(columnsQueryPartList)
	
	currentUnionQueryBlock = qry_TemplateOuterUnionQuery.replace('<DYNAMIC_QUESTION_ANSWERS>',columnsQueryPart)
	currentUnionQueryBlock = currentUnionQueryBlock.replace('<SURVEY_ID>',str(surveyid))
	finalQueryList.append(currentUnionQueryBlock)

finalQuery = 'UNION '.join(finalQueryList)
finalResult = pd.read_sql(finalQuery, sql_conn)

t2=time.time()
print("final result v1: (execution time:%.4f secs)" % (t2-t1))
print(finalResult.head())
print(finalResult.tail())
print(finalResult.info())
print("\n\n")


### second way, more direct python way. maybe less flexible... exact same result (slighty slower execution)
t1=time.time()
# Create pivot of answers vs userid and surveyid
qry_answers = "SELECT UserId,SurveyId,CONCAT('ANS_Q',QuestionId) as Question,Answer_Value FROM Answer"
df_answers = pd.read_sql(qry_answers,sql_conn)
p_df_answers = df_answers.pivot_table(index=['UserId','SurveyId'],columns='Question',values='Answer_Value').reset_index()

# if question exists is survey structure, it means user has not answered --> replace NaN by -1
qry_surveystructure = 'SELECT SurveyId, QuestionId From SurveyStructure'
df_surveystructure = pd.read_sql(qry_surveystructure,sql_conn)
for idx,struct in df_surveystructure.iterrows():
    surveyid = struct['SurveyId']
    questionid = struct['QuestionId']
    p_df_answers_filled = p_df_answers.loc[p_df_answers['SurveyId']==surveyid,'ANS_Q'+str(questionid)].fillna(-1)
    p_df_answers.loc[p_df_answers['SurveyId']==surveyid,'ANS_Q'+str(questionid)] = p_df_answers_filled

finalResult2 = p_df_answers.sort_values(by=['SurveyId','UserId'])
t2=time.time()

print("final result v2: (execution time:%.4f secs)" % (t2-t1))
print(finalResult2.head())
print(finalResult2.tail())
print(finalResult2.info())