# SQL ENGETO final assignment
CREATE TABLE tk_engeto_final (
	SELECT date, country, confirmed
	FROM covid19_basic_differences cbd) ;

# tests performed column
ALTER TABLE tk_engeto_final 
	ADD tests_performed DECIMAL ;

# tests performed values
UPDATE tk_engeto_final
	INNER JOIN covid19_tests
		ON tk_engeto_final.date = covid19_tests.date 
			AND tk_engeto_final.country = covid19_tests.country
				SET tk_engeto_final.tests_performed = covid19_tests.tests_performed ; 

# population column
ALTER TABLE tk_engeto_final 
	ADD population DECIMAL ;

# population values
UPDATE tk_engeto_final 
	INNER JOIN countries 
		ON tk_engeto_final.country = countries.country 
			SET tk_engeto_final.population = countries.population ;
		
# week/weekend column
ALTER TABLE tk_engeto_final 
	ADD week_weekend DECIMAL ;

# week/weekend values (0/1)
UPDATE tk_engeto_final 
	SET week_weekend =  (CASE WHEN WEEKDAY(date) IN (0, 1, 2, 3, 4) THEN 0 ELSE 1 END) ;

# season column
ALTER TABLE tk_engeto_final 
	ADD season DECIMAL ;

# season values (0 - spring, 1 - summer, 2 - autumn, 3 - winter
UPDATE tk_engeto_final 
	SET season = (CASE WHEN MONTH (date) IN (3, 4, 5) THEN 0
					   WHEN MONTH (date) IN (6, 7, 8) THEN 1
					   WHEN MONTH (date) IN (9, 10, 11) THEN 2
					   ELSE 3 END) ;

# population density column
ALTER TABLE tk_engeto_final 
	ADD population_density DECIMAL ;

# population density values
UPDATE tk_engeto_final 
	INNER JOIN countries 
		ON tk_engeto_final.country = countries.country 
			SET tk_engeto_final.population_density = countries.population_density ;

# median age column
ALTER TABLE tk_engeto_final 
	ADD median_age_2018 DECIMAL ;

# median age values
UPDATE tk_engeto_final 
	INNER JOIN countries 
		ON tk_engeto_final.country = countries.country 
			SET tk_engeto_final.median_age_2018 = countries.median_age_2018 ;

# life expectancy 1965 column
ALTER TABLE tk_engeto_final 
	ADD life_expectancy_1965 DECIMAL ;

# life expectancy 1965 values
UPDATE tk_engeto_final 
	INNER JOIN life_expectancy 
		ON tk_engeto_final.country = life_expectancy.country 
			SET tk_engeto_final.life_expectancy_1965 = life_expectancy.life_expectancy 
				WHERE life_expectancy.`year` = 1965 ;

# life expectancy 2015 column
ALTER TABLE tk_engeto_final 
	ADD life_expectancy_2015 DECIMAL ;

# life expectancy 2015 values
UPDATE tk_engeto_final 
	INNER JOIN life_expectancy 
		ON tk_engeto_final.country = life_expectancy.country 
			SET tk_engeto_final.life_expectancy_2015 = life_expectancy.life_expectancy 
				WHERE life_expectancy.`year` = 2015 ;

# life expectancy difference column
ALTER TABLE tk_engeto_final 
	ADD life_expectancy_diff DECIMAL ;

# life expectancy difference values
UPDATE tk_engeto_final 
	SET tk_engeto_final.life_expectancy_diff = ABS(tk_engeto_final.life_expectancy_2015 - tk_engeto_final.life_expectancy_1965) ; 

# drop redundant columns, keep only difference column
ALTER TABLE tk_engeto_final 
	DROP COLUMN life_expectancy_1965 ;

ALTER TABLE tk_engeto_final 
	DROP COLUMN life_expectancy_2015 ;

# helper table for weather data
CREATE TABLE tk_engeto_final_weather
	(SELECT city, date, hour, temp, rain, wind
		FROM weather w2) ;
	
# country column
ALTER TABLE	tk_engeto_final_weather 
	ADD country TEXT ;
	
# country values
UPDATE tk_engeto_final_weather
	INNER JOIN countries
		ON tk_engeto_final_weather.city = countries.capital_city
			SET tk_engeto_final_weather.country = countries.country ;

# substitution of Czech Republic with Czechia
UPDATE tk_engeto_final_weather
	SET tk_engeto_final_weather.country = REPLACE (tk_engeto_final_weather.country, 'Czech Republic', 'Czechia')
		WHERE tk_engeto_final_weather.country = 'Czech Republic' ;
	
# grouped table - average temperature, maximum wind, non-null rain
CREATE TABLE tk_weather_grouped
	(SELECT country, date, hour, (AVG(temp)) avg_temp, (MAX(wind)) max_wind, (CASE WHEN rain > 0 THEN (COUNT(rain > 0)) ELSE 'no rain on this day' END) non_null_rain_hours
		FROM tk_engeto_final_weather
			GROUP BY country, date) ;
		
# average temperature column
ALTER TABLE tk_engeto_final 
	ADD average_temperature DECIMAL ;

# average temperature values
UPDATE tk_engeto_final 
	INNER JOIN tk_weather_grouped
		ON tk_engeto_final.country = tk_weather_grouped.country
			AND tk_engeto_final.date = tk_weather_grouped.date
				SET tk_engeto_final.average_temperature = tk_weather_grouped.avg_temp ;

# maximum wind column
ALTER TABLE tk_engeto_final 
	ADD maximum_wind DECIMAL ;

# maximum wind values
UPDATE tk_engeto_final 
	INNER JOIN tk_weather_grouped
		ON tk_engeto_final.country = tk_weather_grouped.country
			AND tk_engeto_final.date = tk_weather_grouped.date
				SET tk_engeto_final.maximum_wind = tk_weather_grouped.max_wind ;	
			
# non-null rain hours column
ALTER TABLE tk_engeto_final 
	ADD non_null_rain_hours BINARY ;

# non-null rain hours values
UPDATE tk_engeto_final 
	INNER JOIN tk_weather_grouped
		ON tk_engeto_final.country = tk_weather_grouped.country
			AND tk_engeto_final.date = tk_weather_grouped.date
				SET tk_engeto_final.non_null_rain_hours = (CAST (tk_weather_grouped.non_null_rain_hours AS BINARY)) ; 			

# rename the table
ALTER TABLE tk_engeto_final 
	RENAME TO t_tomas_kozak_projekt_SQL_final ;

# gdp per capita column and values
ALTER TABLE t_tomas_kozak_projekt_SQL_final 
	ADD gdp_per_capita DECIMAL ;
	
# gini index column and values
ALTER TABLE t_tomas_kozak_projekt_SQL_final
	ADD gini_index DECIMAL ; 
		
# religion share column
ALTER TABLE t_tomas_kozak_projekt_SQL_final
	ADD religion_share DECIMAL ;

# religion share values
UPDATE t_tomas_kozak_projekt_SQL_final 
	INNER JOIN country_rel_share
		ON t_tomas_kozak_projekt_SQL_final.country = country_rel_share.country
			SET t_tomas_kozak_projekt_SQL_final.religion_share = country_rel_share.rel_share ;

# final table
SELECT * FROM t_tomas_kozak_projekt_SQL_final ttkpsf ;


