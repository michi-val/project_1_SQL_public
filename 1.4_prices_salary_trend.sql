-- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- vytvoření view pro extrakci potřebných dat z tabulky "primary_final"
CREATE OR REPLACE VIEW v_salary_price_CZ_yearly_1_4_help AS
WITH salary_price_year_comparison AS (
  SELECT *
  FROM
  	(SELECT 
  		payroll_year AS payroll_year_a
  		,ROUND(AVG(avg_salary),2) AS avg_salary_year 
  	FROM t_michael_faltynek_project_sql_primary_final AS tmfpspf 
  	GROUP BY payroll_year_a) AS a_salary
  JOIN 
  	(SELECT 
  		payroll_year AS payroll_year_b
  		,ROUND(AVG(price), 2) AS avg_price_year
  	FROM t_michael_faltynek_project_sql_primary_final AS tmfpspf 
  	GROUP BY payroll_year_b) AS b_price
  ON a_salary.payroll_year_a = b_price.payroll_year_b)
SELECT 
	payroll_year_a
	,avg_salary_year 
	,avg_price_year
FROM salary_price_year_comparison;

--
SELECT *
FROM v_salary_price_cz_yearly_1_4_help AS vspcyh 

-- vytvoření tabulky s požadovanými daty procentuálního porování růstu cen a mezd
CREATE OR REPLACE TABLE t_price_salary_comp_1_4_fin
WITH salary_price_1_4_help AS (
  SELECT 
  	payroll_year_a
  	,avg_salary_year 
  	,LAG(avg_salary_year) OVER (ORDER BY payroll_year_a) AS previous_value_sal	
  	,avg_price_year
  	,LAG(avg_price_year) OVER (ORDER BY payroll_year_a) AS previous_value_pr	
  FROM v_salary_price_cz_yearly_1_4_help )
SELECT 
	payroll_year_a  AS year
	,avg_salary_year 
	,avg_price_year
	,ROUND((((avg_salary_year - previous_value_sal) / previous_value_sal) *100) , 2) AS salary_comp_perc
	,ROUND((((avg_price_year - previous_value_pr) / previous_value_pr) *100) , 2) AS price_comp_perc
	,CAST(NULL AS float) AS difference_perc		-- přidání sloupce "difference_perc" pro srovnání rozdílu růstu/poklesu cen a platů
FROM salary_price_1_4_help;

-- naplnění sloupce "difference_perc" daty 
UPDATE t_price_salary_comp_1_4_fin
SET difference_perc = price_comp_perc - salary_comp_perc; 

SELECT *
FROM t_price_salary_comp_1_4_fin AS tpscf;
