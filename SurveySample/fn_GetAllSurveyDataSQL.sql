-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE OR ALTER FUNCTION fn_GetAllSurveyDataSQL()

RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @strQueryTemplateForAnswerColumn nvarchar(max);
	DECLARE @strQueryTemplateForNullColumn nvarchar(max);
	DECLARE @strQueryTemplateOuterUnionQuery nvarchar(max);
	DECLARE @CurrentSurveyId int;
	--DECLARE @CurrentSurveyDescription nvarchar(max)

	SET @strQueryTemplateForAnswerColumn = ' 
			COALESCE(	
				(
				SELECT 
					a.Answer_Value
				FROM 
					Answer as a 
				WHERE 
					a.UserId=u.UserId 
					AND a.SurveyId= <SURVEY_ID>
					AND a.QuestionId= <QUESTION_ID>
				)
				, -1) As ANS_Q<QUESTION_ID>
			  ';
	
	SET @strQueryTemplateForNullColumn = ' 
			NULL As ANS_Q<QUESTION_ID>
			 ';

	SET @strQueryTemplateOuterUnionQuery = ' 
			SELECT 
				u.UserId
				,u.User_Name
				,<SURVEY_ID> as SurveyId
				,<DYNAMIC_QUESTION_ANSWERS>
			FROM 
				[User] as u
			WHERE
				EXISTS(
					SELECT 
						* 
					FROM 
						Answer as a
					WHERE
						a.UserId=u.UserId
						AND a.SurveyId = <SURVEY_ID>
				)
			 ';
	

	DECLARE @strCurrentUnionQueryBlock nvarchar(max);
	SET @strCurrentUnionQueryBlock = '';

	DECLARE @strFinalQuery nvarchar(max);
	SET @strFinalQuery = '';

	-- Cursors kind like generators in Python
	-- No @ in front of Cursors
	DECLARE SurveyCursor CURSOR FOR
		SELECT 
			s.SurveyId
			--, s.SurveyDescription
		FROM 
			Survey AS s
		ORDER BY 
			SurveyId;

	/* when opening cursor, positionned before first row*/
	OPEN SurveyCursor
	-- Could be used with several variables
	-- FETCH NEXT FROM SurveyCursor INTO @CurrentSurveyId, @CurrentSurveyDescription;
	FETCH NEXT FROM SurveyCursor INTO @CurrentSurveyId;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Main loop, over all surveys
		-- for each survey in @currenturveyid, we need to construct the answer col queries
		-- another iteration over the questions of the survey
			-- Surveyid, questionid, flag insurvey indicating whether the question is in the survey
			DECLARE currentQuestionCursor CURSOR FOR
					SELECT 
						*
					FROM
					(
						SELECT
							SurveyId,
							QuestionId,
							1 as InSurvey
						FROM
							SurveyStructure
						WHERE
							SurveyId = @currentSurveyId
						UNION
						SELECT 
							@currentSurveyId as SurveyId,
							Q.QuestionId,
							0 as InSurvey
						FROM
							Question as Q
						WHERE NOT EXISTS
						(
							SELECT *
							FROM SurveyStructure as S
							WHERE S.SurveyId = @currentSurveyId AND S.QuestionId = Q.QuestionId
						)
					) as t
					ORDER BY QuestionId;
			
			DECLARE @currentSurveyIdInQuestion int;
			DECLARE @currentQuestionId int;
			DECLARE @currentinSurvey int;
			
			OPEN currentQuestionCursor;
			FETCH NEXT FROM currentQuestionCursor INTO @currentSurveyIdInQuestion,@currentQuestionId,@currentinSurvey;
			
			DECLARE @strColumnsQueryPart nvarchar(max);
			SET @strColumnsQueryPart = '';
			
			WHILE @@FETCH_STATUS = 0  -- FETCH STATUS Is localized between begin and end
			BEGIN
				-- inner loop iterates over the question
				-- is the current question in the current survey
				IF @currentinSurvey = 0 -- current question not in survey
				BEGIN
					-- then block
					-- spec: col value will be null
					SET @strColumnsQueryPart = @strColumnsQueryPart + 
						REPLACE(@strQueryTemplateForNullColumn,'<QUESTION_ID>', @currentQuestionId)
				END;
				ELSE
				BEGIN
					-- else block
					SET @strColumnsQueryPart = @strColumnsQueryPart + 
						REPLACE(@strQueryTemplateForAnswerColumn,'<QUESTION_ID>', @currentQuestionId)
				END;
				
				FETCH NEXT FROM currentQuestionCursor INTO @currentSurveyIdInQuestion,@currentQuestionId,@currentinSurvey;

				IF @@FETCH_STATUS = 0
				BEGIN
					SET @strColumnsQueryPart = @strColumnsQueryPart + ',';
				END;
			END;

			CLOSE currentQuestionCursor;
			DEALLOCATE currentQuestionCursor;

			SET @strCurrentUnionQueryBlock = REPLACE(@strQueryTemplateOuterUnionQuery,'<DYNAMIC_QUESTION_ANSWERS>',@strColumnsQueryPart)

			SET @strCurrentUnionQueryBlock = REPLACE(@strCurrentUnionQueryBlock,'<SURVEY_ID>',@CurrentSurveyId)

			SET @strFinalQuery = @strFinalQuery + @strCurrentUnionQueryBlock

		FETCH NEXT FROM SurveyCursor INTO @CurrentSurveyId;

		IF @@FETCH_STATUS = 0
		BEGIN
			SET @strFinalQuery = @strFinalQuery + 'UNION'
		END;
	END;
	-- do not forget to close / deallocate cursors (ressources)
	CLOSE SurveyCursor;
	DEALLOCATE SurveyCursor;
	--SELECT @strFinalQuery
	--exec sp_executesql @strFinalQuery

	-- Return the result of the function
	RETURN @strFinalQuery

END
GO

