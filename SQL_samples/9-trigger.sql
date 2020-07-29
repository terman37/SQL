-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
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
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER TRIGGER trg_refreshSurveyView
   ON  dbo.SurveyStructure 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @strSQLSurveyData nvarchar(max)
	SET @strSQLSurveyData = 'CREATE OR ALTER VIEW vw_AllSurveyData AS ';
	SET @strSQLSurveyData = @strSQLSurveyData + (SELECT [dbo].[fn_GetAllSurveyDataSQL]())
	EXEC sp_executesql @strSQLSurveyData
END
GO
