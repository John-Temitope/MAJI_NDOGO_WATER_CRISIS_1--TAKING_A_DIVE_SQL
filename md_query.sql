---
-- The dataset is first loaded into the schema from the cleaned query provided
USE md_water_services; 

-- I view the tables present in the dataset
SHOW TABLES;

-- Crosscheck the location table and see the kind of data available
SELECT * FROM location LIMIT 10;

-- Cross checking the visit table and see the kind of data in the table
SELECT * FROM visits LIMIT 10;

-- Taking a look at the water source table
SELECT * FROM water_source LIMIT 10;

-- Taking a peep at the data dictionary table
SELECT * FROM data_dictionary;

-- Taking a look at the other tables
SELECT * FROM employee LIMIT 5;
SELECT * FROM global_water_access LIMIT 5;
SELECT * FROM water_quality LIMIT 5;
SELECT * FROM well_pollution LIMIT 5;

-- To find all the unique types of water sources
SELECT DISTINCT type_of_water_source FROM water_source;

-- Records from visits table where the time_in_queue is more than some crazy time, say 500 mins
SELECT * FROM visits WHERE time_in_queue > 500;

-- complex query to select data where time in queue is greater than 500 from the source_id table
SELECT * FROM water_source WHERE source_id IN (SELECT source_id FROM visits 
		WHERE time_in_queue > 500);
										-- OR
SELECT * FROM water_source
    WHERE source_id IN 	("AkKi00881224", 
						"AkLu01628224", 
						"AkRu05234224", 
						"HaRu19601224",
						"HaZa21742224",
						"SoRu36096224",
						"SoRu37635224",
						"SoRu38776224");
                        
-- How many visits was made for shared_tap_water and other water sources?
-- For shared_tap_water
SELECT 
		wat.record_id,
		wat.subjective_quality_score,
		wat.visit_count,
		wat_sou.type_of_water_source,
		wat_sou.number_of_people_served
	FROM water_quality AS wat
    JOIN water_source AS wat_sou
	WHERE wat_sou.type_of_water_source = "shared_tap";

-- For tap_in_home
SELECT
		wat.record_id,
        wat.subjective_quality_score,
        wat.visit_count,
        wat_sou.type_of_water_source,
        wat_sou.number_of_people_served
	FROM water_quality AS wat
    JOIN water_source AS wat_sou
    WHERE wat_sou.type_of_water_source = "tap_in_home";
    
    -- For tap in home broken
SELECT
		wat.record_id,
        wat.subjective_quality_score,
        wat.visit_count,
        wat_sou.type_of_water_source,
        wat_sou.number_of_people_served
	FROM water_quality AS wat
    JOIN water_source AS wat_sou
    WHERE wat_sou.type_of_water_source = "tap_in_home_broken";
    
	-- For well
SELECT
		wat.record_id,
        wat.subjective_quality_score,
        wat.visit_count,
        wat_sou.type_of_water_source,
        wat_sou.number_of_people_served
	FROM water_quality AS wat
    JOIN water_source AS wat_sou
    WHERE wat_sou.type_of_water_source = "well";
    
	-- For River
SELECT
		wat.record_id,
        wat.subjective_quality_score,
        wat.visit_count,
        wat_sou.type_of_water_source,
        wat_sou.number_of_people_served
	FROM water_quality AS wat
    JOIN water_source AS wat_sou
    WHERE wat_sou.type_of_water_source = "river";

-- checking the relationship between the water quality table and the visits table
	SELECT 	visits.record_id,
			visits.source_id,
            wat_sou.type_of_water_source,
            wat.subjective_quality_score,
            visits.visit_count,
            visits.time_in_queue
		FROM visits
			JOIN water_source AS wat_sou ON visits.source_id = wat_sou.source_id
            JOIN water_quality AS wat ON visits.record_id = wat.record_id;
          
            
-- To find the records where subjective quality score is 10 and found in home taps, 
		-- and where the source was visited a second time
SELECT * FROM water_quality
	WHERE subjective_quality_score = 10 AND visit_count = 2;

-- Table displaying for contamination data for all the well sources
SELECT * FROM well_pollution;

-- Query that checks if the results is Clean but the biological column is > 0.01
SELECT * FROM well_pollution
	WHERE results = "Clean" AND biological >= 0.01;
    
-- Query to check descriptions with Clean in the records
SELECT * FROM well_pollution 
	WHERE description LIKE "Clean_%";

/* Case 1a: Update description that mistakenly mention 
	 'Clean Bacteria: Giardia Lamblia' to 'Bacteria: Giardia Lamblia'
 Case 1b: Update description that mistakenly mention
	 'Clean Bacteria: E. coli' to 'Bacteria: E. coli'
 Case 2: Update the 'results' column from 'Clean to 'Contaminated: Biological'
	where the 'biological' column has a value greater than 0.01 and 'results' is 'Clean' 
    Its best to create a copy before proceeding to update a table incase of mistakes */

SET SQL_SAFE_UPDATES = 0;

-- Creating a table copy to use before updating the original in the database
DROP TABLE IF EXISTS `well_pollution_copy`;
CREATE TABLE
	well_pollution_copy AS 
		(SELECT * FROM well_pollution);
        SELECT * FROM well_pollution_copy;
        UPDATE well_pollution_copy
			SET description = "Bacteria: Giardia Lamblia"
			WHERE description = "Clean Bacteria: Giardia Lamblia" AND biological >= 0.01;
		UPDATE well_pollution_copy
			SET description = "Bacteria: E. coli"
			WHERE description = "Clean Bacteria: E. coli" AND biological >= 0.01;
		UPDATE well_pollution_copy
			SET results = "Contaminated: Biological"
			WHERE results = "Clean" AND biological >= 0.01; 	
		DROP TABLE md_water_services.well_pollution_copy;		-- We drop the table_copy after we have set the conditions

UPDATE well_pollution
	SET description = "Bacteria: Giardia Lamblia"
    WHERE description = "Clean Bacteria: Giardia Lamblia" AND biological = 0.01;
UPDATE well_pollution
	SET description = "Bacteria: E. coli"
    WHERE description = "Clean Bacteria: E. coli" AND biological = 0.01;
UPDATE well_pollution
	SET results = "Contaminated: Biological"
    WHERE results = "Clean" AND biological = 0.01;

-- Displaying the table to show if the erroreous rows are fixed
SELECT * FROM well_pollution
	WHERE description LIKE "Clean_%";
    