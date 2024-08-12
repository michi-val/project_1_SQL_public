-- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- vytvoření tabulky pro extrakci dat z primary final + vytvoření sloupce "comparison" pro porovnání růstu/poklesu
CREATE OR REPLACE TABLE t_value_comparison_avg_commodity_price_year
WITH commodity_trend_help_data AS (	
	SELECT 
		payroll_year 
		,category_code 
		,commodity_name 
		,round(avg(price), 2) avg_price 
		,ammount 
		,unit  
	FROM t_michael_faltynek_project_sql_primary_final tmfpspf 
	GROUP BY category_code, payroll_year)
SELECT 
	*
	,lag(avg_price) OVER (ORDER BY category_code, payroll_year) previous_value
	,CASE
		WHEN category_code != LAG(category_code) OVER (ORDER BY category_code, payroll_year) THEN  NULL 
		WHEN LAG(category_code) OVER (ORDER BY category_code, payroll_year) IS NULL THEN NULL 
    WHEN avg_price > LAG(avg_price) OVER (ORDER BY category_code, payroll_year) THEN ('higher')
    ELSE 'not higher'
  END AS comparison
FROM commodity_trend_help_data;

-- přidání sloupce "comparison_perc" pro procentuální porovnání
ALTER TABLE t_value_comparison_avg_commodity_price_year 
ADD COLUMN comparison_perc float;

-- naplnění comparison_perc
UPDATE t_value_comparison_avg_commodity_price_year 
SET comparison_perc = 
	CASE 
		WHEN comparison IS NULL THEN NULL 
		ELSE round((((avg_price - previous_value) / previous_value) *100) , 2)
	END;

-- 
SELECT *
FROM t_value_comparison_avg_commodity_price_year tvcacpy;

-- průměrný meziroční nárůst jednotlivých produktů za celé období vzestupně
SELECT 
	commodity_name 
	,round(avg(comparison_perc),2) avg_price_trend
FROM t_value_comparison_avg_commodity_price_year tvcacpy 
GROUP BY category_code 
ORDER BY avg_price_trend;


