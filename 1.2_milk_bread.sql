-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- Mléko polotučné pasterované
-- Chléb konzumní kmínový

CREATE OR REPLACE TABLE t_milk_bread
WITH milk_bread AS (
  SELECT *
  FROM 
    (SELECT 
	    payroll_year
    	,commodity_name 
    	,round(avg(price),2) price_avg_yearly
    	,currency 
      FROM t_michael_faltynek_project_sql_primary_final tmfpspf 
      WHERE (payroll_year = 2006 OR payroll_year = 2018) 
      	AND (commodity_name LIKE '%Mléko polotučné pasterované%' 
      			OR commodity_name LIKE '%Chléb konzumní kmínový%')
      GROUP BY payroll_year, commodity_name) AS a 
  JOIN 
    (SELECT 
      payroll_year payroll_year_2
      ,round(avg(avg_salary),2) salary_avg_yearly
    FROM t_michael_faltynek_project_sql_primary_final tmfpspf 
    WHERE  payroll_year = 2006 OR payroll_year = 2018
    GROUP BY payroll_year) AS b
      ON a.payroll_year = b.payroll_year_2)
  SELECT 
  	payroll_year
  	,salary_avg_yearly
  	,commodity_name
  	,price_avg_yearly
  	,round(salary_avg_yearly/price_avg_yearly,2) 'kg/l per year'
  FROM milk_bread;

SELECT *
FROM t_milk_bread tmb;
