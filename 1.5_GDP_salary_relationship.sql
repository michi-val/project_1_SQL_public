/* 
1.5 Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, 
projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem? 
*/

-- Vytvoření pomocného view
CREATE OR REPLACE VIEW v_GDP_salary_price_help AS
SELECT *
FROM t_price_salary_comp_1_4_fin AS tpscf 
JOIN
	(WITH gdp_help AS (
		SELECT 
			YEAR AS year_GDP 
			,GDP 
			,LAG(GDP) OVER (ORDER BY year) AS previous_value_GDP
		FROM economies AS e
		WHERE country = 'czech republic' AND year BETWEEN 2006 AND 2018
		ORDER BY YEAR)
	SELECT 
		year_GDP
		,GDP
		,ROUND((((GDP - previous_value_GDP) / previous_value_GDP) *100) , 2) AS GDP_comp_perc
	FROM gdp_help) AS gdp_help_sel
ON tpscf.year = gdp_help_sel.year_GDP;

-- 
SELECT *
FROM v_gdp_salary_price_help AS vgsph; 

SELECT *
FROM t_price_salary_comp_1_4_fin AS tpscf;
--

-- požadované seřazení sloupců z pomocného view a vytvoření tabulky
CREATE OR REPLACE TABLE t_GDP_price_salary_1_5
SELECT
	`year` 
	,avg_salary_year
	,avg_price_year
	,GDP
	,salary_comp_perc 
	,price_comp_perc 
	,GDP_comp_perc 
FROM v_gdp_salary_price_help AS vgsph;

SELECT *
FROM t_gdp_price_salary_1_5 AS tgps ;

-- pomocný SELECT s méně sloupcy
SELECT 
	`year` 
	,GDP_comp_perc 
	,salary_comp_perc 
	,price_comp_perc 
FROM t_gdp_price_salary_1_5 AS tgps ;

-- pomocný výpočet průměrných hodnot za celé sledované období 
SELECT 
	ROUND(AVG(salary_comp_perc),2)
	,ROUND(AVG(price_comp_perc),2)
	,ROUND(AVG(GDP_comp_perc),2)
FROM t_gdp_price_salary_1_5 AS tgps;
