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
CREATE OR REPLACE FUNCTION Distancia(p1 GEOMETRY, s2 GEOMETRY)
RETURNS NUMERIC
AS
$$
    DECLARE
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
            -- Get coordinates from Point and LineString --
            p1x := ST_X(p1);
            p1y := ST_y(p1);
            segp1x := ST_X(segp1);
            segp2x := ST_X(segp2);
            segp1y := ST_Y(segp1);
            segp2y := ST_Y(segp2);
            -- Check the range of Lon and Lat values --
            CALL CheckLonLat(p1x, p1y);
            CALL CheckLonLat(segp1x, segp1y);
            CALL CheckLonLat(segp2x, segp2y);
        END;
        -- Block to compute distance --
          BEGIN
            -- Distance between segments points --
            distx := segp2x - segp1x;
            disty := segp2y - segp1y;
            -- Compute Distance --
            h := disty * (p1x - segp1x) - distx * (p1y - segp1y);
        END;
        RETURN h;
    END;
$$
LANGUAGE plpgsql;

/* 
    @desc Function to verify if two points overlaps
    @param a Numeric value
    @param b Numeric value
    @param c Numeric value
    @param d Numeric value
    @return A boolean value that corresponds if two points overlaps.
*/
CREATE OR REPLACE FUNCTION overlap(a NUMERIC, b NUMERIC, c NUMERIC, d NUMERIC)
RETURNS BOOL
AS
$$
    BEGIN
        RETURN (LEAST(a, b) <= GREATEST(c, d)) AND (LEAST(c, d) <= GREATEST(a, b));
    END;
$$
LANGUAGE plpgsql;

/* 
    @desc Function to verify if two segments intersects.
    @param s1 A GEOMETRY type corresponding to a LineString.
    @param s2 A GEOMETRY type corresponding to a LineString.
    @return A boolean value that corresponds if two segments intersects.
*/
CREATE OR REPLACE FUNCTION SegIntersects(s1 GEOMETRY, s2 GEOMETRY)
RETURNS BOOL
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
        -- distance definions --
        dists1p1 NUMERIC;
        dists1p2 NUMERIC;
        dists2p1 NUMERIC;
        dists2p2 NUMERIC;
        -- s1 definitions --
        seg1p1 GEOMETRY;
        seg1p2 GEOMETRY;
        seg1p1x NUMERIC;
        seg1p2x NUMERIC;
        seg1p1y NUMERIC;
        seg1p2y NUMERIC;
        -- s2 definitions --
        seg2p1 GEOMETRY;
        seg2p2 GEOMETRY;
        seg2p1x NUMERIC;
        seg2p2x NUMERIC;
        seg2p1y NUMERIC;
        seg2p2y NUMERIC;
    BEGIN
        -- Block to check the input values --
        BEGIN
            -- -- Check p1 and s2 params -- 
            CALL CheckGeom(s1, 'ST_LineString'); 
            CALL CheckGeom(s2, 'ST_LineString');
            -- Get coordinates from Segment1 -- 
            seg1p1 := ST_PointN(s1, 1);
            seg1p2 := ST_PointN(s1, 2);
            
            seg1p1x := ST_X(seg1p1);
            seg1p2x := ST_X(seg1p2);
            seg1p1y := ST_Y(seg1p1);
            seg1p2y := ST_Y(seg1p2);
            -- Get coordinates from Segment2 --
            seg2p1 := ST_PointN(s2, 1);
            seg2p2 := ST_PointN(s2, 2);

            seg2p1x := ST_X(seg2p1);
            seg2p2x := ST_X(seg2p2);
            seg2p1y := ST_Y(seg2p1);
            seg2p2y := ST_Y(seg2p2);
        END;
        -- Block to verify if two segments intersects --
        BEGIN
            -- Distance between segment1 and points from segments2
            dists1p1 := Distancia(seg2p1, s1);
            dists1p2 := Distancia(seg2p2, s1);
            -- Collinear case
            IF ( dists1p1 = 0 AND dists1p2 = 0 ) THEN
                -- Vertical case --
                IF ( seg1p1x = seg1p2x ) THEN
                    RAISE NOTICE 'verical case';
                    RETURN overlap(seg1p1y, seg1p2y, seg2p1y, seg2p2y);
                -- Horizontal case --
                ELSE
                    RAISE NOTICE 'horizontal case';
                    RETURN overlap(seg1p1x, seg1p2x, seg2p1x, seg2p2x); 
                END IF;
            -- Non-collinear case --
            ELSE    
                RAISE NOTICE 'non-colinear';
                dists2p1 := Distancia(seg1p1, s2);
                dists2p2 := Distancia(seg1p2, s2);
                RETURN ((dists1p1 * dists1p2 <= 0) AND (dists2p1 * dists2p2 <= 0));
            END IF;
        END;
    END;
$$
LANGUAGE plpgsql;

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