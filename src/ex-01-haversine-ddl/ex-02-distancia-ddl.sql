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
    @desc Function to calculate distance between a point and segment
    @param p1 A GEOMETRY of type POINT.
    @param s2 A GEOMETRY of type LINESTRING.
    @return A value that corresponds to distance.
*/
CREATE OR REPLACE FUNCTION DistanciaDDL(p1 GEOMETRY, s2 GEOMETRY)
RETURNS NUMERIC
AS
$$
    DECLARE
        num NUMERIC DEFAULT 0.0;
        den NUMERIC DEFAULT 0.0;
        h NUMERIC;
        disty NUMERIC DEFAULT 0.0;
        distx NUMERIC DEFAULT 0.0;
        -- p1 definitions --
        p1x NUMERIC;
        p1y NUMERIC;
        -- s2 definitions --
        segp1 GEOMETRY;
        segp2 GEOMETRY;
        segp1x NUMERIC;
        segp2x NUMERIC;
        segp1y NUMERIC;
        segp2y NUMERIC;
    BEGIN
        -- Block to check the input values --
        BEGIN
            -- Check p1 and s2 params -- 
            CALL CheckGeom(p1, 'ST_Point'); 
            CALL CheckGeom(s2, 'ST_LineString');
            segp1 := ST_PointN(s2, 1);
            segp2 := ST_PointN(s2, 2);
            -- Get coordinates from Point and LineString         
            p1x := ST_X(p1);
            p1y := ST_y(p1);
            segp1x := ST_X(segp1);
            segp2x := ST_X(segp2);
            segp1y := ST_Y(segp1);
            segp2y := ST_Y(segp2);
            -- Check the range of Lon and Lat values ---
            CALL CheckLonLat(p1x, p1y);
            CALL CheckLonLat(segp1x, segp1y);
            CALL CheckLonLat(segp2x, segp2y);
        END;
        -- Compute distance between point and segment --
        BEGIN
            -- Difference between segments points
            distx := segp2x - segp1x;
            disty := segp2y - segp1y;
            -- Compute denominator --
            den := sqrt(distx * distx + disty * disty);
            IF( den <= 0 ) THEN
                RAISE EXCEPTION 'Invalid case.';
            END IF;
            -- Compute numerator --
            num := disty * (p1x - segp1x) - distx * (p1y - segp1x);
            -- Compute distance --
            h := num / den;
        END;
        RETURN abs(h);
    END;
$$
LANGUAGE plpgsql;

-- Dummy example --
SELECT DistanciaDDL(
    ST_GeometryFromText('POINT( 6 10 )', 4326),
    ST_GeometryFromText('LINESTRING( 2 2, 8 8 )', 4326)
);

-- Distance between Sao jose dos campos and Reservatorio Irapé --
SELECT DistanciaDDL(
    ST_GeometryFromText('POINT( -45.88581788 -23.18613808 )', 4326),
    ST_GeometryFromText('LINESTRING( -42.82270441 -17.02857408, -42.61057065 -16.73966339 )', 4326)
);