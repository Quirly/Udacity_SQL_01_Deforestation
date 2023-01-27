'(START) Create View for project'
CREATE VIEW forestation
AS
SELECT fa.country_code AS country_code_short,
       fa.country_name AS country_name,
       fa.year AS year_short,
       fa.forest_area_sqkm AS forest_area_sqkm,
       (la.total_area_sq_mi*2.59) AS land_area_sqkm,
        r.region AS region, r.income_group AS income_group,
       (forest_area_sqkm/(la.total_area_sq_mi*2.59)) AS percent_forest
  FROM forest_area fa
  JOIN land_area la
    ON fa.country_code=la.country_code AND fa.year=la.year
  JOIN regions r
    ON r.country_code=la.country_code

'(1) Queries related to section 1: GLOBAL SITUATION'

'Paragraph 1-1: SUM forest_areas WORLD in years 1990 and 2016'
SELECT country_code_short,
       country_name,
       year_short,
       CAST(SUM(forest_area_sqkm) AS DECIMAL(20,2))
FROM forestation
WHERE country_name='World' AND year_short IN (1990,2016)
GROUP BY 1,2,3

'Paragraph 1-1: SUM loss or relative forest_area in world year 2016 compared to 1990'
SELECT CAST((sub_2016_to_1990.diff_forest_area*100/sub_2016_to_1990.year_before) AS DECIMAL(4,2)) AS rel_forest_loss_percent
FROM (
SELECT country_code_short AS country_code_short,
                           year_short AS year_short,
                           year_before AS year_before,
                           ((sub_loss.forest_area_sqkm-sub_loss.year_before)*(-1)) AS diff_forest_area,
                           CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(4,2)) AS rel_forest
FROM (SELECT country_code_short,
             country_name,
             year_short,
             lag(forest_area_sqkm) OVER(ORDER BY year_short) AS year_before,
             forest_area_sqkm,
             land_area_sqkm
        FROM forestation
       WHERE country_name='World' AND year_short IN (1990,2016)) sub_loss) sub_2016_to_1990

'Paragraph 1-2: Country with land_area slightly smaller than loss of forest_area in world in year 2016'
WITH diff_table AS (SELECT country_code_short AS country_code_short,
                           year_short AS year_short,
                           ((sub_loss.forest_area_sqkm-sub_loss.year_before)*(-1)) AS diff_forest_area
                      FROM (SELECT country_code_short,
                                   country_name,
                                   year_short,
                                   lag(forest_area_sqkm) OVER(ORDER BY year_short) AS year_before,
                                   forest_area_sqkm
                                   FROM forestation
                                   WHERE country_name='World' AND year_short IN (1990,2016))sub_loss
                    WHERE year_short = 2016)

SELECT forestation.country_code_short,
       forestation.country_name,
       CAST(forestation.land_area_sqkm AS INTEGER),
       forestation.year_short,
       CAST(diff_table.diff_forest_area AS DECIMAL(20,2))
FROM forestation
JOIN diff_table
ON diff_table.year_short = forestation.year_short
WHERE forestation.land_area_sqkm<diff_table.diff_forest_area
ORDER BY forestation.land_area_sqkm DESC
LIMIT 1

'(2) Queries related to section 2: REGIONAL OUTLOOK'

'Paragraph (2-1): relative forest_area (forest_pct) in world in 2016'
SELECT country_name,
       year_short,
       (CAST(SUM(forest_area_sqkm)*100/SUM(land_area_sqkm) AS DECIMAL(20,2))) AS forest_pct,
       CAST(SUM(land_area_sqkm) AS DECIMAL(20,2)) AS land,
       CAST(SUM(forest_area_sqkm) AS DECIMAL(20,2)) AS forest
FROM forestation
WHERE country_name='World' AND year_short =2016
GROUP BY 1,2

'Paragraph (2-1): region with highest relative forestation (forest_percent) in 2016'
SELECT region,
       year_short,
      CAST((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100) AS DECIMAL(4,2)) AS forest_percent
FROM forestation
WHERE year_short =2016 AND region !='World'
GROUP BY 1,2
ORDER BY forest_percent DESC
LIMIT 1

'Paragraph (2-1): region with lowest relative forestation (forest_percent) in 2016'
SELECT region,
       year_short,
      CAST((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100) AS DECIMAL(4,2)) AS forest_percent
FROM forestation
WHERE year_short =2016 AND region !='World'
GROUP BY 1,2
ORDER BY forest_percent ASC
LIMIT 1

'Paragraph (2-2): relative forest_area (forest_pct) in world in 1990'
SELECT country_name,
       year_short,
       (CAST(SUM(forest_area_sqkm)*100/SUM(land_area_sqkm) AS DECIMAL(20,2))) AS forest_pct,
       CAST(SUM(land_area_sqkm) AS DECIMAL(20,2)) AS land,
       CAST(SUM(forest_area_sqkm) AS DECIMAL(20,2)) AS forest
FROM forestation
WHERE country_name='World' AND year_short =1990
GROUP BY 1,2

'Paragraph (2-2): region with highest relative forestation (forest_percent) in 2016'
SELECT region,
       year_short,
      CAST((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100) AS DECIMAL(4,2)) AS forest_percent
FROM forestation
WHERE year_short =1990 AND region !='World'
GROUP BY 1,2
ORDER BY forest_percent DESC
LIMIT 1

'Paragraph (2-2): region with lowest relative forestation (forest_percent) in 2016'
SELECT region,
       year_short,
      CAST((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100) AS DECIMAL(4,2)) AS forest_percent
FROM forestation
WHERE year_short =1990 AND region !='World'
GROUP BY 1,2
ORDER BY forest_percent ASC
LIMIT 1

'Paragraph (2-3): Table (2.1),1st and 2nd column: regions with relative forestation in 1990'
SELECT region,
      CAST((SUM(forest_area_sqkm)*100/SUM(land_area_sqkm)) AS DECIMAL(4,2)) AS forest_percent
FROM forestation
WHERE year_short =1990 AND region !='World'
GROUP BY 1
ORDER BY region ASC

'Paragraph (2-3):Table (2.1),3rd column: regions with relative forestation in 2016'
SELECT region,
      CAST((SUM(forest_area_sqkm)*100/SUM(land_area_sqkm)) AS DECIMAL(4,2)) AS forest_percent
FROM forestation
WHERE year_short =2016 AND region !='World'
GROUP BY 1
ORDER BY region ASC

'Paragraph (2-4): regions with decrease forestation in percent from 1990 to 2016'
WITH table_1990 AS (SELECT region AS region_1990,
      CAST((SUM(forest_area_sqkm)*100/SUM(land_area_sqkm)) AS DECIMAL(4,2)) AS forest_percent
FROM forestation
WHERE year_short =1990 AND region !='World'
GROUP BY 1
ORDER BY region ASC),

    table_2016 AS (SELECT region AS region_2016,
          CAST((SUM(forest_area_sqkm)*100/SUM(land_area_sqkm)) AS DECIMAL(4,2)) AS forest_percent
    FROM forestation
    WHERE year_short =2016 AND region !='World'
    GROUP BY 1
    ORDER BY region ASC)

    SELECT region_1990,
           table_1990.forest_percent AS forest_pct_1990,
           table_2016.forest_percent AS forest_pct_2016,
           CAST((-1)*(table_1990.forest_percent-table_2016.forest_percent)AS DECIMAL(20,2)) AS forest_pct_loss
    FROM table_1990
    JOIN table_2016
    ON table_1990.region_1990=table_2016.region_2016
    WHERE CAST((-1)*(table_1990.forest_percent-table_2016.forest_percent)AS DECIMAL(20,2))<0
    ORDER BY forest_pct_loss ASC

'(3) Queries related to section 3: COUNTRY-LEVEL DETAIL'

'(Paragraph 3-1): Success Stories: Two countries with highest total increase forestation in 1990 vs. 2016'
SELECT diff_abs.country_name,
       CAST(diff_abs.lag AS DECIMAL(20,2)) AS forest_1990,
       CAST(diff_abs.forest_area_sqkm AS DECIMAL(20,2)) AS forest_2016,
       CAST((diff_abs.forest_area_sqkm-diff_abs.lag) AS DECIMAL(20,2)) AS change_abs
  FROM ( SELECT country_name,
                lag(forest_area_sqkm) OVER(ORDER BY country_name,year_short ASC) AS lag,
                year_short,
                forest_area_sqkm
           FROM (SELECT country_name,
                        year_short,
                        (SUM(forest_area_sqkm)) AS forest_area_sqkm
                   FROM forestation
                  WHERE year_short IN (1990,2016) AND country_name !='World'
               GROUP BY 1,2
               ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests) diff_abs
WHERE year_short=2016 AND  (diff_abs.forest_area_sqkm-diff_abs.lag) IS NOT NULL
ORDER BY change_abs DESC
LIMIT 2

'(Paragraph 3-1): country with highest relative forestation in 1990 vs. 2016'
SELECT diff_abs.country_name,
       CAST(diff_abs.lag AS DECIMAL(20,2)) AS forest_1990,
       CAST(diff_abs.forest_area_sqkm AS DECIMAL(20,2)) AS forest_2016,
       CAST((diff_abs.forest_area_sqkm-diff_abs.lag) AS DECIMAL(20,2)) AS change_abs,
       CAST(((diff_abs.forest_area_sqkm-diff_abs.lag)*100)/diff_abs.lag AS DECIMAL(20,2)) AS change_rel_pct
  FROM ( SELECT country_name,
                lag(forest_area_sqkm) OVER(ORDER BY country_name,year_short ASC) AS lag,
                year_short,
                forest_area_sqkm,
                land_area_sqkm
           FROM (SELECT country_name,
                        year_short,
                        (SUM(forest_area_sqkm)) AS forest_area_sqkm,
                        (SUM(land_area_sqkm)) AS land_area_sqkm
                   FROM forestation
                  WHERE year_short IN (1990,2016) AND country_name !='World'
               GROUP BY 1,2
               ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests) diff_abs
WHERE year_short=2016 AND  (diff_abs.forest_area_sqkm-diff_abs.lag) IS NOT NULL
ORDER BY change_rel_pct DESC
LIMIT 1


'(Paragraph 3-2): Table 3.1: Five countries with highest total decrease forestation in 1990 vs. 2016'
SELECT region,
       diff_abs.country_name,
       CAST(diff_abs.lag AS DECIMAL(20,2)) AS forest_1990,
       CAST(diff_abs.forest_area_sqkm AS DECIMAL(20,2)) AS forest_2016,
       CAST((diff_abs.forest_area_sqkm-diff_abs.lag) AS DECIMAL(20,2)) AS change_abs
  FROM ( SELECT region,
                country_name,
                lag(forest_area_sqkm) OVER(ORDER BY country_name,year_short ASC) AS lag,
                year_short,
                forest_area_sqkm
           FROM (SELECT region,
                        country_name,
                        year_short,
                        (SUM(forest_area_sqkm)) AS forest_area_sqkm
                   FROM forestation
                  WHERE year_short IN (1990,2016) AND country_name !='World'
               GROUP BY 1,2,3
               ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests) diff_abs
WHERE year_short=2016 AND (diff_abs.forest_area_sqkm-diff_abs.lag) IS NOT NULL
ORDER BY change_abs ASC
LIMIT 5

'(Paragraph 3-3): Table 3.2: Five countries with relative decrease forestation in 1990 vs. 2016'
SELECT diff_abs.country_name,
       CAST(diff_abs.lag AS DECIMAL(20,2)) AS forest_1990,
       CAST(diff_abs.forest_area_sqkm AS DECIMAL(20,2)) AS forest_2016,
       CAST((diff_abs.forest_area_sqkm-diff_abs.lag) AS DECIMAL(20,2)) AS change_abs,
       CAST(((diff_abs.forest_area_sqkm-diff_abs.lag)*100)/diff_abs.lag AS DECIMAL(20,2)) AS change_rel
  FROM ( SELECT country_name,
                lag(forest_area_sqkm) OVER(ORDER BY country_name,year_short ASC) AS lag,
                year_short,
                forest_area_sqkm,
                land_area_sqkm
           FROM (SELECT country_name,
                        year_short,
                        (SUM(forest_area_sqkm)) AS forest_area_sqkm,
                        (SUM(land_area_sqkm)) AS land_area_sqkm
                   FROM forestation
                  WHERE year_short IN (1990,2016) AND country_name !='World'
               GROUP BY 1,2
               ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests) diff_abs
WHERE year_short=2016 AND  (diff_abs.forest_area_sqkm-diff_abs.lag) IS NOT NULL
ORDER BY change_rel ASC
LIMIT 5

'(Paragraph 3-6): Table 3.3: Count of countries in each quartile'
SELECT percentiles,
       COUNT(*) AS number_of_countries
FROM ( SELECT country_name,
       CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) AS rel_forest,
       CASE WHEN (forest_area_sqkm*100/land_area_sqkm)  >= 75 THEN 4
            WHEN (forest_area_sqkm*100/land_area_sqkm)  >=50 AND (forest_area_sqkm*100/land_area_sqkm) <75 THEN 3
            WHEN (forest_area_sqkm*100/land_area_sqkm)  >=25 AND (forest_area_sqkm*100/land_area_sqkm) <50 THEN 2
            WHEN (forest_area_sqkm*100/land_area_sqkm)  >0 AND (forest_area_sqkm*100/land_area_sqkm) <25 THEN 1 END AS PERCENTILES
         FROM (SELECT country_name,
                      year_short,
                      (SUM(forest_area_sqkm)) AS forest_area_sqkm,
                      (SUM(land_area_sqkm)) AS land_area_sqkm
                 FROM forestation
                WHERE year_short = 2016 AND country_name !='World'
             GROUP BY 1,2
             ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests
                WHERE CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) IS NOT NULL
             ORDER BY rel_forest DESC) sub
GROUP BY percentiles
ORDER BY 1

'(Paragraph 3-7): Countries in Top Percentile (Group with highest relative forestation)'
SELECT region AS region,
       country_name AS country_with_over_75_percent_forest,
       rel_forest AS rel_forest,
       percentiles AS percentile_group
FROM ( SELECT region,
              country_name,
              CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) AS rel_forest,
              CASE WHEN (forest_area_sqkm*100/land_area_sqkm)  >= 75 THEN 4
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >=50 AND (forest_area_sqkm*100/land_area_sqkm) <75 THEN 3
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >=25 AND (forest_area_sqkm*100/land_area_sqkm) <50 THEN 2
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >0 AND (forest_area_sqkm*100/land_area_sqkm) <25 THEN 1 END AS PERCENTILES
        FROM (SELECT region,
      		           country_name,
                     year_short,
                     (SUM(forest_area_sqkm)) AS forest_area_sqkm,
                     (SUM(land_area_sqkm)) AS land_area_sqkm
                FROM forestation
               WHERE year_short = 2016 AND country_name !='World'
            GROUP BY 1,2,3
            ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests
        WHERE CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) IS NOT NULL
        ORDER BY rel_forest DESC) sub_table_rel_forest
WHERE percentiles = 4

'(Paragraph 3-8): Number of countries in Top Percentile'
SELECT COUNT(*) AS number_of_countries_in_top_quartile
FROM (
SELECT region AS region,
       country_name AS country_with_over_75_percent_forest,
       rel_forest AS rel_forest,
       percentiles AS percentile_group
FROM ( SELECT region,
              country_name,
              CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) AS rel_forest,
              CASE WHEN (forest_area_sqkm*100/land_area_sqkm)  >= 75 THEN 4
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >=50 AND (forest_area_sqkm*100/land_area_sqkm) <75 THEN 3
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >=25 AND (forest_area_sqkm*100/land_area_sqkm) <50 THEN 2
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >0 AND (forest_area_sqkm*100/land_area_sqkm) <25 THEN 1 END AS PERCENTILES
        FROM (SELECT region,
      		           country_name,
                     year_short,
                     (SUM(forest_area_sqkm)) AS forest_area_sqkm,
                     (SUM(land_area_sqkm)) AS land_area_sqkm
                FROM forestation
               WHERE year_short = 2016 AND country_name !='World'
            GROUP BY 1,2,3
            ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests
        WHERE CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) IS NOT NULL
        ORDER BY rel_forest DESC) sub_table_rel_forest
WHERE percentiles = 4) sub_percentile_4

'(Paragraph 3-9): Number of countries with higher percentage of forestation than the US'
WITH table_countries AS (SELECT region AS region,
                                country_name AS country_name,
                                rel_forest AS rel_forest,
                                percentiles AS percentile_group
                           FROM ( SELECT region, country_name,
                                  CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) AS rel_forest,
                                  CASE WHEN (forest_area_sqkm*100/land_area_sqkm)  >= 75 THEN 4
                                       WHEN (forest_area_sqkm*100/land_area_sqkm)  >=50 AND (forest_area_sqkm*100/land_area_sqkm) <75 THEN 3
                                       WHEN (forest_area_sqkm*100/land_area_sqkm)  >=25 AND (forest_area_sqkm*100/land_area_sqkm) <50 THEN 2
                                       WHEN (forest_area_sqkm*100/land_area_sqkm)  >0 AND (forest_area_sqkm*100/land_area_sqkm) <25 THEN 1
                                  END AS PERCENTILES
                                  FROM (SELECT region,
      		                                       country_name,
                                                 year_short,
                                                (SUM(forest_area_sqkm)) AS forest_area_sqkm,
                                                (SUM(land_area_sqkm)) AS land_area_sqkm
                                            FROM forestation
                                           WHERE year_short = 2016 AND country_name !='World'
                                        GROUP BY 1,2,3
                                        ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests
                              WHERE CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) IS NOT NULL
                              ORDER BY rel_forest DESC) sub_table_rel_forest),

        table_US AS (SELECT country_name,
                            rel_forest AS rel_forest_US
                       FROM table_countries
                      WHERE country_name LIKE 'United States')

SELECT COUNT(*) AS number_of_countries_with_higher_forestation_than_US
FROM table_countries
WHERE rel_forest > (SELECT rel_forest_US FROM table_us)

'(Paragraph 3-10): Table3.4: Countries in Top Percentile (Group with highest relative forestation)'
SELECT region AS region,
       country_name AS country_with_over_75_percent_forest,
       rel_forest AS rel_forest,
       percentiles AS percentile_group
FROM ( SELECT region,
              country_name,
              CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) AS rel_forest,
              CASE WHEN (forest_area_sqkm*100/land_area_sqkm)  >= 75 THEN 4
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >=50 AND (forest_area_sqkm*100/land_area_sqkm) <75 THEN 3
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >=25 AND (forest_area_sqkm*100/land_area_sqkm) <50 THEN 2
              WHEN (forest_area_sqkm*100/land_area_sqkm)  >0 AND (forest_area_sqkm*100/land_area_sqkm) <25 THEN 1 END AS PERCENTILES
        FROM (SELECT region,
      		           country_name,
                     year_short,
                     (SUM(forest_area_sqkm)) AS forest_area_sqkm,
                     (SUM(land_area_sqkm)) AS land_area_sqkm
                FROM forestation
               WHERE year_short = 2016 AND country_name !='World'
            GROUP BY 1,2,3
            ORDER BY forest_area_sqkm ASC) sub_country_absolute_forests
        WHERE CAST((forest_area_sqkm*100/land_area_sqkm) AS DECIMAL(20,2)) IS NOT NULL
        ORDER BY rel_forest DESC) sub_table_rel_forest
WHERE percentiles = 4
