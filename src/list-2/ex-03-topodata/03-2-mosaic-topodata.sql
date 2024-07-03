--
-- Create a template table to resample images
--
CREATE TABLE template AS 
    SELECT 1 as rid,
    ST_AddBand(ST_MakeEmptyRaster(10800, 7200, -61.5, -11.0, 0.0002777784814814818, -0.0002777775000000002, 0, 0, 4326), 1, '8BUI') as rast; 

--
-- Resample image based on template rast
--
UPDATE topodata SET rast = ST_Resample(topodata.rast, template.rast) from template;

--
-- Create a new table to store topodata images
--
CREATE TABLE topodata_mosaic AS
    SELECT ST_Union(t.rast) AS rast,
    'MOSAIC' AS fid 
    FROM topodata AS t;

--
-- Verify mosaic metadata
--
SELECT ST_MetaData(rast) from topodata_mosaic;