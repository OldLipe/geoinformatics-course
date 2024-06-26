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
    @desc Function to cauculates polygon area.
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

-- Dummy example --
SELECT PolyArea(
    ST_GeometryFromText('POLYGON(( 1 1, 2 2, 3 1, 1 0, 1 1 ))', 4326)
);

-- Rondonia state simplified with Convex Hull --
SELECT PolyArea(
    ST_GeometryFromText(
        'POLYGON(( -60.7175323799999 -13.693700124, 
                   -61.8410940909999 -13.5489138669999, 
                   -64.2908910269999 -12.501406592, 
                   -64.2939750419999 -12.499972963, 
                   -64.4061676099999 -12.447048136, 
                   -64.4072808969999 -12.4464867669999, 
                   -64.4162116269999 -12.4414632209999, 
                   -65.0305266619999 -11.996604901, 
                   -65.0320261749999 -11.995080262, 
                   -66.8102531119999 -9.81804587599997, 
                   -66.7821409079999 -9.75857204899995, 
                   -66.4088584189999 -9.40694662199995, 
                   -63.6214269749999 -7.97653173599995, 
                   -63.5005318789999 -7.97632114399993, 
                   -62.8666165719999 -7.97586829700003, 
                   -62.8450557429999 -7.98653125199997, 
                   -62.7439724949999 -8.04528606600001, 
                   -61.630554879 -8.72195842400003, 
                   -61.5235880409999 -8.81859663699991, 
                   -61.5208395119999 -8.82158536100002, 
                   -59.9767765859999 -11.1223888899999, 
                   -59.9171930599999 -11.338434586, 
                   -59.7743528519999 -12.340955739, 
                   -60.3840328489999 -13.449229196, 
                   -60.3879196279999 -13.454695112, 
                   -60.4320020879999 -13.4884355809999, 
                   -60.7093148879999 -13.6930033639999, 
                   -60.7175323799999 -13.693700124 ))', 4326)
);