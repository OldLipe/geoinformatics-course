/* 
    @desc Procedure to check geometry type
    @param geom      A GEOMETRY type
    @param geom_type Type of geometry in text
*/
CREATE OR REPLACE PROCEDURE CheckGeom(geom GEOMETRY, 
                                      geom_type text DEFAULT 'ST_Point')
AS 
$$
    BEGIN
        IF( (ST_GeometryType(geom) <> geom_type) ) THEN
            RAISE EXCEPTION 'Invalid geometry type.';
        END IF;
    END;
$$
LANGUAGE plpgsql;

/* 
    @desc Procedure to check longitude and latitude values
    @param lon A numeric value refered to longitude
    @param lat A numeric value refered to latitude
*/
CREATE OR REPLACE PROCEDURE CheckLonLat(lon NUMERIC DEFAULT 0.0, 
                                        lat NUMERIC DEFAULT 0.0)
AS 
$$
    BEGIN
        IF( (lon < -180 OR lon > 180) ) THEN
            RAISE EXCEPTION 'Invalid longitude range.';
        END IF;
        IF( (lat < -90 OR lat > 90) ) THEN
            RAISE EXCEPTION 'Invalid latitude range.';
        END IF;
    END;
$$
LANGUAGE plpgsql;

/* 
    @desc Function to calculate distance between two points
    @param p1 A GEOMETRY of type POINT.
    @param p2 A GEOMETRY of type POINT.
    @return A value that corresponds to distance in kilometers.
*/
CREATE OR REPLACE FUNCTION DistanciaHaversine(p1 GEOMETRY, p2 GEOMETRY)
RETURNS NUMERIC
AS
$$
    DECLARE
        r NUMERIC DEFAULT 6371;
        -- Distance result --
        dist NUMERIC DEFAULT 0.0;
        -- Radian value --
        radian NUMERIC DEFAULT pi() / 180;
        -- Point coordinates --
        p1x NUMERIC;
        p1y NUMERIC;
        p2x NUMERIC;
        p2y NUMERIC;
        -- Sines of point 2 and 1 --
        sinx NUMERIC;
        siny NUMERIC;
    BEGIN
        -- Block to check the input values --
        BEGIN
            -- Check if p1 and p2 are points -- 
            CALL CheckGeom(p1); 
            CALL CheckGeom(p2);
            -- Check the range of Lon and Lat values ---
            p1x := ST_X(p1);
            p2x := ST_X(p2);
            p1y := ST_Y(p1);
            p2y := ST_Y(p2);
            CALL CheckLonLat(p1x, p1y);
            CALL CheckLonLat(p2x, p2y);
        END;
        -- Block to convert to radians --
        BEGIN
            p1x := p1x * radian;
            p2x := p2x * radian;
            p1y := p1y * radian;
            p2y := p2y * radian;
        END;
        -- Block to compute Haversine distance --
        BEGIN
            -- Compute sines --
            sinx := sin( (p2x - p1x) / 2 );
            siny := sin( (p2y - p1y) / 2 );
            -- Compute distance --
            dist := power( siny, 2 ) + cos(p1y) * cos(p2y) * power( sinx, 2 ); 
            dist := 2 * r * asin(sqrt(dist));
        END;
        RETURN dist;
    END;
$$
LANGUAGE plpgsql;

-- Dummy example --
SELECT DistanciaHaversine(
    ST_GeometryFromText('POINT( 2 1 )', 4326),
    ST_GeometryFromText('POINT( 2 2 )', 4326)
);

-- Distance between Oiaque and Chuí --
-- https://mundoeducacao.uol.com.br/geografia/pontos-extremos-do-brasil.htm
SELECT DistanciaHaversine(
    ST_GeometryFromText('POINT( -51.6376 4.5088 )', 4326),
    ST_GeometryFromText('POINT( -53.3954 -33.7511 )', 4326)
);