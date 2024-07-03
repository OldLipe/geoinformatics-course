--
-- Create NDWI indce in a new table for T21LWE tile
--
CREATE TABLE indices_t21lwe AS
    SELECT t1.rid, 
    ST_MapAlgebra(t1.rast, 1, t2.rast, 1, '( ([rast1] - [rast2]) / ([rast1] + [rast2]) ) * 10000', '16BSI', 'FIRST', '(0)', '(0)', '-9999') AS rast,
    'S2A_NDWI_20240629T135711_N0510_R067_T21LWE_20240629T211952' AS fid 
    FROM t21lwe_20240629 AS t1,
         t21lwe_20240629 AS t2
    WHERE t1.fid = 'S2A_B03_20240629T135711_N0510_R067_T21LWE_20240629T211952.tif' AND
          t2.fid = 'S2A_B08_20240629T135711_N0510_R067_T21LWE_20240629T211952.tif' AND
          ST_Envelope(t1.rast) = ST_Envelope(t2.rast);

--
-- Create NDVI indice into created table for T21LWE tile
--
INSERT INTO indices_t21lwe (rid, rast, fid) 
(
    SELECT t1.rid, 
        ST_MapAlgebra(t1.rast, 1, t2.rast, 1, '( ([rast1] - [rast2]) / ([rast1] + [rast2]) ) * 10000', '16BSI', 'FIRST', '(0)', '(0)', '-9999') AS rast,
        'S2A_NDVI_20240629T135711_N0510_R067_T21LWE_20240629T211952' AS fid 
    FROM t21lwe_20240629 AS t1,
         t21lwe_20240629 AS t2
    WHERE t1.fid = 'S2A_B08_20240629T135711_N0510_R067_T21LWE_20240629T211952.tif' AND
          t2.fid = 'S2A_B04_20240629T135711_N0510_R067_T21LWE_20240629T211952.tif' AND
          ST_Envelope(t1.rast) = ST_Envelope(t2.rast)
);

--
-- Set NoData value
--
UPDATE indices_t21lwe SET rast = ST_SetBandNoDataValue(rast, 1, -9999);

--
-- Create NDWI indce in a new table for T21LWF tile
--
CREATE TABLE indices_t21lwf AS
    SELECT t1.rid, 
    ST_MapAlgebra(t1.rast, 1, t2.rast, 1, '( ([rast1] - [rast2]) / ([rast1] + [rast2]) ) * 10000', '16BSI', 'FIRST', '(0)', '(0)', '-9999') AS rast,
    'S2A_NDWI_20240629T135711_N0510_R067_T21LWF_20240629T211952' AS fid 
    FROM t21lwf_20240629 AS t1,
         t21lwf_20240629 AS t2
    WHERE t1.fid = 'S2A_B03_20240629T135711_N0510_R067_T21LWF_20240629T211952.tif' AND
          t2.fid = 'S2A_B08_20240629T135711_N0510_R067_T21LWF_20240629T211952.tif' AND
          ST_Envelope(t1.rast) = ST_Envelope(t2.rast);

--
-- Create NDVI indice into created table for T21LWF tile
--
INSERT INTO indices_t21lwf (rid, rast, fid) 
(
    SELECT t1.rid, 
        ST_MapAlgebra(t1.rast, 1, t2.rast, 1, '( ([rast1] - [rast2]) / ([rast1] + [rast2]) ) * 10000', '16BSI', 'FIRST', '(0)', '(0)', '-9999') AS rast,
        'S2A_NDVI_20240629T135711_N0510_R067_T21LWF_20240629T211952' AS fid 
    FROM t21lwf_20240629 AS t1,
         t21lwf_20240629 AS t2
    WHERE t1.fid = 'S2A_B08_20240629T135711_N0510_R067_T21LWF_20240629T211952.tif' AND
          t2.fid = 'S2A_B04_20240629T135711_N0510_R067_T21LWF_20240629T211952.tif' AND
          ST_Envelope(t1.rast) = ST_Envelope(t2.rast)
);

--
-- Set NoData value
--
UPDATE indices_t21lwf SET rast = ST_SetBandNoDataValue(rast, 1, -9999);