-- Simple intersect as x form --
SELECT SegIntersects(
    ST_GeometryFromText('LINESTRING( 3.5 0.5, 4 1 )', 4326),
    ST_GeometryFromText('LINESTRING( 3.5 1, 4 0.5 )', 4326)
);

-- No intersection example --
SELECT SegIntersects(
    ST_GeometryFromText('LINESTRING( 3.5 0.5, 4 1 )', 4326),
    ST_GeometryFromText('LINESTRING( 3.5 1, 3.5 1.5 )', 4326)
);

-- Collinear vertical case --
SELECT SegIntersects(
    ST_GeometryFromText('LINESTRING( 3.5 1 , 3.5 0.5 )', 4326),
    ST_GeometryFromText('LINESTRING( 3.5 1, 3.5 1.5 )', 4326)
);

-- Collinear horizontal case --
SELECT SegIntersects(
    ST_GeometryFromText('LINESTRING( 3.6 1, 4 1 )', 4326),
    ST_GeometryFromText('LINESTRING( 3.8 1, 4.2 1 )', 4326)
);