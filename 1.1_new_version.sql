-- 1.1 Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- vytvoření view pro extrakci dat o platech z tab. primary_final
CREATE OR REPLACE VIEW v_salary_trend_help_data AS
SELECT 
	payroll_year
	,industry_branch_code 
	,AVG(avg_salary) AS avg_salary_year
	,industry_branch_name 
FROM t_michael_faltynek_project_sql_primary_final AS tmfpspf 
GROUP BY industry_branch_code, industry_branch_name, payroll_year;

SELECT *
FROM v_salary_trend_help_data AS vsthd;

-- vytvoření tabulky s porovnáním platů vzestupně
CREATE OR REPLACE TABLE t_value_comparison_avg_salary_year AS
SELECT
		LAG_help.payroll_year
		,LAG_help.industry_branch_code 
		,LAG_help.industry_branch_name 
		,LAG_help.avg_salary_year
		,LAG_help.previous_value
		,CASE 
			WHEN LAG_help.avg_salary_year > LAG_help.previous_value THEN ('higher')
			WHEN LAG_help.avg_salary_year < LAG_help.previous_value THEN ('not higher')
		END AS comparison
		,ROUND((((LAG_help.avg_salary_year - LAG_help.previous_value) / LAG_help.previous_value) *100) , 2) AS comparison_perc
FROM (
	SELECT
		payroll_year
		,industry_branch_code
		,industry_branch_name 
		,avg_salary_year
		,LAG(avg_salary_year) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS previous_value
	FROM v_salary_trend_help_data) AS LAG_help;
		

SELECT *  
FROM t_value_comparison_avg_salary_year AS tvcasy ;









-- DOPLŇUJÍCÍ UKAZATELÉ: 

-- průměrný meziroční nárůst jednotlivých odvětví za celé období
SELECT 
	industry_branch_name 
	,ROUND(AVG(comparison_perc),2) AS avg_salary_trend
FROM t_value_comparison_avg_salary_year AS tvcasy
GROUP BY industry_branch_name 
ORDER BY avg_salary_trend;

-- procentuální nárůst mezi 2006 a 2018
WITH 2006to2018_trend AS (
SELECT *
FROM 
(SELECT 
	industry_branch_code AS ibc1
	,industry_branch_name 
	,avg_salary_year AS y_2006
FROM t_value_comparison_avg_salary_year AS tvcasy 
WHERE payroll_year = 2006) AS a
JOIN 
(SELECT 
	industry_branch_code 
	,avg_salary_year AS y_2018
FROM t_value_comparison_avg_salary_year AS tvcasy 
WHERE payroll_year = 2018) AS b
ON a.ibc1 = b.industry_branch_code)
SELECT 
	industry_branch_name 
	,y_2006
	,y_2018
	,ROUND((((y_2018-y_2006)/y_2006)*100),2) AS perc_diff_06_18
FROM 2006to2018_trend
ORDER BY perc_diff_06_18 DESC;

-- pomocný select pro zjištění počtu poklesů
SELECT 
	comparison 
	,COUNT(comparison) 
FROM t_value_comparison_avg_salary_year AS tvcasy 
GROUP BY comparison;
