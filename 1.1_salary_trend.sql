-- ## 1.1 Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- vytvoření view pro extrakci dat o platech z tab. primary_final
CREATE OR REPLACE VIEW v_salary_trend_help_data AS
SELECT 
	payroll_year
	,industry_branch_code 
	,avg(avg_salary) avg_salary_year
	,industry_branch_name 
FROM t_michael_faltynek_project_sql_primary_final tmfpspf 
GROUP BY industry_branch_code , payroll_year ;

SELECT *
FROM v_salary_trend_help_data vsthd;

-- vytvoření tabulky s porovnáním platů vzestupně
CREATE OR REPLACE TABLE t_value_comparison_avg_salary_year AS
SELECT 
  payroll_year
	,industry_branch_code 
	,industry_branch_name 
	,avg_salary_year
	,LAG(avg_salary_year) OVER (ORDER BY industry_branch_code , payroll_year) AS previous_value
  ,CASE
	  WHEN industry_branch_code != LAG(industry_branch_code) OVER (ORDER BY industry_branch_code , payroll_year) THEN  NULL
    WHEN avg_salary_year > LAG(avg_salary_year) OVER (ORDER BY industry_branch_code , payroll_year) THEN ('higher')
    ELSE 'not higher'
  END AS comparison
FROM v_salary_trend_help_data;   

-- přidání sloupce do tabulky pro dopočet procentuálního rozdílů platů
ALTER TABLE t_value_comparison_avg_salary_year 
ADD COLUMN comparison_perc float;

-- naplnění sloupce s procentuálním vyjádřením rozdílů platů v období 2006 - 2018
UPDATE t_value_comparison_avg_salary_year 
SET comparison_perc = CASE 
		                    WHEN comparison IS NULL THEN NULL  
		                    ELSE round((((avg_salary_year - previous_value) / previous_value) *100) , 2)
	                    END;SELECT *
  
FROM t_value_comparison_avg_salary_year tvcasy ;

-- doplňující ukazatel: průměrný meziroční nárůst jednotlivých odvětví za celé období
SELECT 
	industry_branch_name 
	,round(avg(comparison_perc),2) avg_salary_trend
FROM t_value_comparison_avg_salary_year tvcasy
GROUP BY industry_branch_code 
ORDER BY avg_salary_trend;