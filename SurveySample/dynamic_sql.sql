use Survey_Sample_A18;

DECLARE @myquery nvarchar(1000);
SET @myquery  = 'SELECT * FROM Survey WHERE SurveyId=';
SET @myquery = @myquery + '3';
EXEC(@myquery);

/* MANUAL QUERY*/
SELECT 
	u.UserId
	,u.[User_Name]
	,COALESCE((SELECT a.Answer_Value FROM Answer as a where a.SurveyId=1 and a.QuestionId=1 and a.UserId=u.UserId),-1) as Q1
	,COALESCE((SELECT a.Answer_Value FROM Answer as a where a.SurveyId=1 and a.QuestionId=2 and a.UserId=u.UserId),-1) as Q2
FROM 
	[User] as u
