USE [Survey_Sample_A18]
GO

DECLARE @RC int
DECLARE @nbRows int


SET @nbRows=1000
-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[generateRandomSurveyResponses] 
   @nbRows
GO


