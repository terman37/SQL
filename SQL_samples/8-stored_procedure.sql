USE [Survey_Sample_A18]
GO
/****** Object:  StoredProcedure [dbo].[generateRandomSurveyResponses]    Script Date: 11-Feb-20 18:49:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[generateRandomSurveyResponses] 
	-- Add the parameters for the stored procedure here
	@nbRows int = 100 --default = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @currentSurveyId int;
	DECLARE @currentQuestionId int;
	DECLARE @currentUserId int;
	DECLARE @loop int;
	DECLARE @existanceCount int;

	SET @loop = 0;

	WHILE @loop < @nbRows
	BEGIN
		
		SET @currentSurveyId = (select top(1) SurveyId from Survey order by newid());
		SET @currentQuestionId = (select top(1) QuestionId 
					from SurveyStructure 
					where SurveyId = @currentSurveyId  order by newid());
		SET @currentUserId = (select top(1) UserId from [User] order by newid());

		SET @existanceCount = (SELECT COUNT(UserId) From Answer 
							where UserId = @currentUserId
							and SurveyId = @currentSurveyId
							and QuestionId = @currentQuestionId)

		IF @existanceCount = 0
		BEGIN
			INSERT INTO [dbo].[Answer]
				   ([QuestionId] ,[SurveyId] ,[UserId] ,[Answer_Value])
			 VALUES (@currentQuestionId ,@currentSurveyId ,@currentUserId ,
					convert(int, RAND()*10));
		END;
		
		SET @loop = @loop + 1;
	 END;

END
