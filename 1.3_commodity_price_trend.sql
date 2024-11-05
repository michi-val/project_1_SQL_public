-- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- vytvoření tabulky pro extrakci dat z primary final + vytvoření sloupců "comparison" a "comparison_perc" pro porovnání růstu/poklesu

CREATE OR REPLACE TABLE t_value_comparison_avg_commodity_price_year_new AS
SELECT 
	commodity_ss.payroll_year 
	,commodity_ss.category_code
	,commodity_ss.commodity_name 
	,commodity_ss.ammount
	,commodity_ss.unit
	,commodity_ss.avg_price 
	,commodity_ss.previous_value
	,CASE
		WHEN commodity_ss.avg_price > commodity_ss.previous_value THEN ('higher')
		WHEN commodity_ss.avg_price < commodity_ss.previous_value THEN ('not higher')
 	END AS comparison
 	,ROUND((((commodity_ss.avg_price - commodity_ss.previous_value) / commodity_ss.previous_value) *100) , 2) AS comparison_perc
FROM (
	SELECT 
		payroll_year 
		,category_code 
		,commodity_name 
		,round(avg(price), 2) AS avg_price 
		,ammount 
		,unit
		,LAG(round(avg(price), 2)) OVER (PARTITION BY category_code ORDER BY payroll_year) AS previous_value
	FROM t_michael_faltynek_project_sql_primary_final AS tmfpspf 
	GROUP BY category_code, payroll_year, commodity_name, ammount) AS commodity_ss;
	
-- 
SELECT *
FROM t_value_comparison_avg_commodity_price_year_new AS tvcacpyn;

-- průměrný meziroční nárůst jednotlivých produktů za celé období vzestupně
SELECT 
	commodity_name 
	,ROUND(AVG(comparison_perc), 2) AS avg_price_trend
FROM t_value_comparison_avg_commodity_price_year_new AS tvcacpyn
GROUP BY commodity_name 
ORDER BY avg_price_trend;


