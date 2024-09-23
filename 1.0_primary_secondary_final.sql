-- vytvoření tabulky t_michael_faltynek_project_SQL_primary_final 

CREATE OR REPLACE TABLE t_michael_faltynek_project_SQL_primary_final AS
SELECT
	cp.date_from 
	,cp.date_to 
	,cpc.code AS category_code
	,cpc.name AS commodity_name
	,cp.value AS price
	,cpc.price_value AS ammount
	,cpc.price_unit AS unit
	,cpay.payroll_year 
	,cpay.industry_branch_code 
	,cpay.value AS avg_salary
	,cpu.name AS currency
	,cpib.name AS industry_branch_name
FROM czechia_price AS cp 
JOIN czechia_price_category AS cpc 
	ON cp.category_code = cpc.code 
JOIN czechia_payroll AS cpay
	ON YEAR(cp.date_from) = cpay.payroll_year 
	AND cpay.value_type_code = 5958 
    AND cp.region_code IS NULL
    AND calculation_code = 100
JOIN czechia_payroll_unit AS cpu 
	ON cpay.unit_code = cpu.code 
JOIN czechia_payroll_industry_branch AS cpib 
	ON cpay.industry_branch_code = cpib.code 
ORDER BY cp.date_from;


SELECT *
FROM t_michael_faltynek_project_sql_primary_final t_mf_prim_fin;

-- vytvoření tabulky secondary_final

CREATE OR REPLACE TABLE t_michael_faltynek_project_SQL_secondary_final
SELECT 
	e.country 
	,e.`year` 
	,e.GDP 
	,e.gini 
	,e.population 
FROM countries AS c 
JOIN economies AS e 
	ON c.country = e.country 
WHERE c.continent = 'Europe' 
	AND e.`year` BETWEEN 2006 AND 2018
ORDER BY e.country , e.`year` ;

SELECT *
FROM t_michael_faltynek_project_sql_secondary_final tmfpssf;
