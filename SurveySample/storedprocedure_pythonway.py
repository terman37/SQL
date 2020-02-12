
import pandas as pd
import pyodbc

sql_conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server}; SERVER=LAPTOP-NLGPTOS3;DATABASE=Survey_Sample_A18;Trusted_Connection=yes')

# template query definitions

qry_TemplateForAnswerColumn = 'COALESCE( ' \
				+ '(SELECT a.Answer_Value ' \
				+ 'FROM	Answer as a ' \
				+ 'WHERE a.UserId=u.UserId AND a.SurveyId= <SURVEY_ID> AND a.QuestionId= <QUESTION_ID>) ' \
				+ ', -1) As ANS_Q<QUESTION_ID> '

qry_TemplateForNullColumn = 'NULL As ANS_Q<QUESTION_ID> '

qry_TemplateOuterUnionQuery = 'SELECT u.UserId, u.User_Name, <SURVEY_ID> as SurveyId, <DYNAMIC_QUESTION_ANSWERS> ' \
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
print(finalResult.head())
print(finalResult.info())