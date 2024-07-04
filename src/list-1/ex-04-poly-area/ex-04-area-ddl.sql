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
    @desc Function to calculate area between four points
    @param x1 A NUMERIC value
    @param y2 A NUMERIC value
    @param x2 A NUMERIC value
    @param y1 A NUMERIC value
    @return A NUMERIC value that corresponds to the area.
*/
CREATE OR REPLACE FUNCTION CalcArea(x1 NUMERIC, y2 NUMERIC, 
                                    x2 NUMERIC, y1 NUMERIC)
RETURNS NUMERIC 
AS
$$
    BEGIN
        RETURN x1 * y2 - y1 * x2;
    END;
$$
LANGUAGE plpgsql;

/* 
    @desc Function to calculates polygon area.
    @param p1 A GEOMETRY corresponding to a Polygon.
    @return A NUMERIC value that corresponds to the polygon area.
*/
CREATE OR REPLACE FUNCTION PolyArea(p1 GEOMETRY)
RETURNS NUMERIC
AS
$$
    DECLARE
        area NUMERIC DEFAULT 0.0;
        npoints NUMERIC DEFAULT 3;
        query TEXT;
        -- Coordinates points array --
        pts NUMERIC ARRAY;
        -- p1 definitions --
        p1x NUMERIC;
        p2x NUMERIC;
        
        p1y NUMERIC;
        p2y NUMERIC;
    BEGIN
        -- Block to check the input values --
        BEGIN
            -- Check p1 param -- 
            CALL CheckGeom(p1, 'ST_Polygon'); 
            -- Check provided polygon form
            IF NOT ST_IsSimple(p1) THEN
                RAISE EXCEPTION 'Invalid polygon. Provide a simple one.'; 
            END IF;
        END;
        -- Block to compute polygon area --
        BEGIN
            -- Get number of points --
            npoints := ST_NPoints(p1) - 1;
            -- Transform polygon points into array --
            SELECT ARRAY_AGG (ARRAY[ ST_x((tbl.pt).geom), ST_y((tbl.pt).geom) ] ) 
                INTO pts FROM ( SELECT ST_DumpPoints($1) AS pt ) AS tbl;
            -- Loop in each polygon point --
            FOR i IN 1..npoints LOOP   
                -- Get x coordinates --
                p1x := pts[i][1];
                p2x := pts[i + 1][1];
                -- Get y coordinates --
                p1y := pts[i][2];
                p2y := pts[i + 1][2];
                -- Compute area --
                area := area + CalcArea(p1x, p2y, p2x, p1y);
            END LOOP;
        END;
        RETURN abs(area) / 2;
    END;
$$
LANGUAGE plpgsql;
