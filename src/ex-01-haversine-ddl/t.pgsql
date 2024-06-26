/* 
    @desc This function calculates and returns ...
    @param p1 ...
    @param p2 ...
    @return ...
*/

CREATE OR REPLACE FUNCTION CheckGeom(geom GEOMETRY, 
                                     geom_type text DEFAULT 'ST_Point')
RETURNS VOID 
AS 
$$
    BEGIN
        IF( (ST_GeometryType(geom) <> geom_type) ) THEN
            RAISE EXCEPTION 'Invalid geometry type.';
        END IF;
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CheckLonLat(lon NUMERIC DEFAULT 0.0, 
                                       lat NUMERIC DEFAULT 0.0)
RETURNS VOID 
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


-- https://en.wikipedia.org/wiki/Haversine_formula
-- https://www.vcalc.com/wiki/vCalc/Haversine%20-%20Distance
-- select DistanciaHaversine(ST_GeometryFromText('POINT(0 0)', 4326), ST_GeometryFromText('POINT(1 1)', 4326));
CREATE OR REPLACE FUNCTION DistanciaHaversine(p1 GEOMETRY, p2 GEOMETRY)
RETURNS NUMERIC
AS
$$
    DECLARE
        r NUMERIC DEFAULT 6371;
        dist NUMERIC DEFAULT 0.0;
        -- User definitions --
        p1x NUMERIC;
        p1y NUMERIC;
        p2x NUMERIC;
        p2y NUMERIC;
    BEGIN
        -- Block to check the input values --
        BEGIN
            -- Check if p1 and p2 are points -- 
            CheckGeom(p1); 
            CheckGeom(p2);
            -- Check the range of Lon and Lat values ---
            CheckLonLat(ST_X(p1), ST_Y(p1));
            CheckLonLat(ST_X(p2), ST_Y(p2));
        END;
        -- Block to get coordinates --
        BEGIN
            p1x := ST_X(p1);
            p2x := ST_X(p2);
            p1y := ST_Y(p1);
            p2y := ST_Y(p2);
        END;
        -- Block to compute Haversine distance --
        BEGIN
            -- Compute numerator --
            dist := 1 - cos(p2y - p1y) + cos(p1y) * cos(p2y) * (1 - cos(p2x - p1x));
            -- Compute denomitor --
            dist := 2* r * asin(sqrt(dist / 2));
        END;
        -- Return distance --
        RETURN dist;
    END;
$$
LANGUAGE plpgsql;

-- --
SELECT DistanciaHaversine(
    ST_GeometryFromText('POINT( 1 1)', 4326),
    ST_GeometryFromText('POINT( 2 2)', 4326)
);

-- TODO: computar a distancia entre Chuí e Ailã --


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
            segp1 := ST_PointN(s2, 1);
            segp2 := ST_PointN(s2, 2);
            -- -- Check p1 and s2 params -- 
            -- CheckGeom(p1, 'ST_Point'); 
            -- CheckGeom(s2, 'ST_LineString');
            -- -- Check the range of Lon and Lat values ---
            -- CheckLonLat(ST_X(p1), ST_Y(p1));
            -- CheckLonLat(ST_X(segp1), ST_Y(segp1));
            -- CheckLonLat(ST_X(segp2), ST_Y(segp2));
        END;
        -- Block to compute Haversine distance --
          BEGIN
            p1x := ST_X(p1);
            p1y := ST_y(p1);
            segp1x := ST_X(segp1);
            segp2x := ST_X(segp2);
            segp1y := ST_Y(segp1);
            segp2y := ST_Y(segp2);
            
            -- Compute ... --
            distx := segp2x - segp1x;
            disty := segp2y - segp1y;

            den := sqrt(distx * distx + disty * disty);
            IF( den <= 0 ) THEN
                RAISE EXCEPTION 'Invalid case.';
            END IF;
            -- Compute .... --
            num := disty * (p1x - segp1x) - distx * (p1y - segp1x);
            -- Compute result --
            h := num / den;
        END;
        -- TODO: retonar o modulo --
        RETURN h;
    END;
$$
LANGUAGE plpgsql;

SELECT DistanciaDDL(
    ST_GeometryFromText('POINT( 6 10 )', 4326),
    ST_GeometryFromText('LINESTRING( 2 2, 8 8 )', 4326)
);


--- ----

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
            segp1 := ST_PointN(s2, 1);
            segp2 := ST_PointN(s2, 2);
            -- -- Check p1 and s2 params -- 
            -- CheckGeom(p1, 'ST_Point'); 
            -- CheckGeom(s2, 'ST_LineString');
            -- -- Check the range of Lon and Lat values ---
            -- CheckLonLat(ST_X(p1), ST_Y(p1));
            -- CheckLonLat(ST_X(segp1), ST_Y(segp1));
            -- CheckLonLat(ST_X(segp2), ST_Y(segp2));
        END;
        -- Block to compute Haversine distance --
          BEGIN
            p1x := ST_X(p1);
            p1y := ST_y(p1);
            segp1x := ST_X(segp1);
            segp2x := ST_X(segp2);
            segp1y := ST_Y(segp1);
            segp2y := ST_Y(segp2);
            
            -- Compute ... --
            distx := segp2x - segp1x;
            disty := segp2y - segp1y;

            -- Compute ... --
            h := disty * (p1x - segp1x) - distx * (p1y - segp1x);
        END;
        -- TODO: retonar o modulo --
        RETURN h;
    END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION overlap(a NUMERIC, b NUMERIC, c NUMERIC, d NUMERIC)
RETURNS BOOL
AS
$$
    BEGIN
        RETURN (min(a, b) ≤ max(c, d)) AND (min(c, d) ≤ max(a, b));
    END;
$$
LANGUAGE plpgsql;


--- ---

CREATE OR REPLACE FUNCTION SegIntersect(s1 GEOMETRY, s2 GEOMETRY)
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
        -- s2 definitions --
        seg1p1 GEOMETRY;
        seg1p2 GEOMETRY;
        seg1p1x NUMERIC;
        seg1p2x NUMERIC;
        seg1p1y NUMERIC;
        seg1p2y NUMERIC;

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
            -- CheckGeom(s1, 'ST_LineString'); 
            -- CheckGeom(s2, 'ST_LineString');
            -- -- Check the range of Lon and Lat values ---
            -- CheckLonLat(ST_X(p1), ST_Y(p1));
            -- CheckLonLat(ST_X(segp1), ST_Y(segp1));
            -- CheckLonLat(ST_X(segp2), ST_Y(segp2));
        END;
        -- Block to compute Haversine distance --
        BEGIN

            dists1p1 := Distancia(seg2p1, s1);
            dists1p2 := Distancia(seg2p2, s1);

            seg1p1x := ST_X(seg1p1);
            seg1p2x := ST_X(seg1p2);
            seg1p1y := ST_Y(seg1p1);
            seg1p2y := ST_Y(seg1p2);

            seg2p1x := ST_X(seg2p1);
            seg2p2x := ST_X(seg2p2);
            seg2p1y := ST_Y(seg2p1);
            seg2p2y := ST_Y(seg2p2);

            -- caso sejam colineares
            IF( dists1p1 == 0 AND dists1p2 == 0 ) THEN
                -- caso sejam verticais --
                IF ( seg1p1x == seg1p2x ) THEN
                    RETURN overlap(seg1p1y, seg1p2y, seg2p1y, seg2p2y);
                ELSE 
                   RETURN overlap(seg1p1x, seg1p2x, seg2p1x, seg2p2x); 
                END IF;
            -- caso não sejam colineares --
            ELSE   
                dists2p1 := Distancia(seg1p1, s2);
                dists2p2 := Distancia(seg1p2, s2);
                RETURN (dists1p1 * dists1p2 <= 0) AND (dists2p1 * dists2p2 <= 0);
            END IF;
        END;
    END;
$$
LANGUAGE plpgsql;



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

CREATE OR REPLACE FUNCTION PolyArea(p1 GEOMETRY)
RETURNS NUMERIC
AS
$$
    DECLARE
        area NUMERIC DEFAULT 0.0;
        npoints NUMERIC DEFAULT 3;
        query TEXT;

        res NUMERIC ARRAY;
        -- p1 definitions --
        p1 GEOMETRY;
        p2 GEOMETRY;
        -- --
        p1x NUMERIC;
        p2x NUMERIC;
        -- --
        p1y NUMERIC;
        p2y NUMERIC;
    BEGIN
        -- Block to check the input values --
        BEGIN
            -- -- Check p1 and s2 params -- 
            -- CheckGeom(s1, 'ST_LineString'); 
            -- CheckGeom(s2, 'ST_Polygon');
            -- TODO: checar se o poligono é simples
            -- ST_IsSimple -- ST_IsValid

            -- -- Check the range of Lon and Lat values ---
            -- CheckLonLat(ST_X(p1), ST_Y(p1));
            -- CheckLonLat(ST_X(segp1), ST_Y(segp1));
            -- CheckLonLat(ST_X(segp2), ST_Y(segp2));
        END;
        -- Block to compute Haversine distance --
        
        npoints := ST_NPoints(p1) - 1;
        SELECT ARRAY_AGG (ARRAY[ ST_x((tbl.pt).geom), ST_y((tbl.pt).geom) ] ) 
            INTO res FROM ( SELECT ST_DumpPoints($1) AS pt ) AS tbl;


        -- TODO: remover esse numero 4 ---
        FOR i IN 1..4 LOOP   
            -- --
            p1x := res[i][1];
            p2x := res[i + 1][1];
            -- --
            p1y := res[i][2];
            p2y := res[i + 1][2];
            area := area + CalcArea(p1x, p2y, p2x, p1y);
        END LOOP;
        RETURN abs(area) / 2;
    END;
$$
LANGUAGE plpgsql;

SELECT PolyArea(
    ST_GeometryFromText('POLYGON(( 1 1, 2 2, 3 1, 1 0, 1 1 ))', 4326)
);

-- --


-- Lista cap 8 - prox quinta 04/07

SELECT setseed(0.5);
CREATE TABLE colecao(
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	nome VARCHAR (255) NOT NULL,
	periodo DATERANGE NOT NULL,
	cobertura GEOMETRY NOT NULL,
    CHECK(ST_GeometryType(cobertura) = 'ST_Polygon' OR
          ST_GeometryType(cobertura) = 'ST_MultiPolygon')
);

INSERT INTO colecao (nome, periodo, cobertura)
    VALUES ('CBERS-4-16D', '[2018-01-01, 2023-12-31)',  ST_GeometryFromText('POLYGON(( -67.88 -10.10, -45.33 -10.10, -45.33 -0.36, -67.88 -0.36, -67.88 -10.10 ))', 4326)),
           ('AMAZONIA-1-8D', '[2023-01-01, 2023-12-31)',  ST_GeometryFromText('POLYGON(( -67.88 -10.10, -45.33 -10.10, -45.33 -0.36, -67.88 -0.36, -67.88 -10.10 ))', 4326));

CREATE TABLE cena(
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    colecao_id UUID  REFERENCES colecao(id)
                                ON DELETE NO ACTION
                                ON UPDATE CASCADE,
	nome_cena VARCHAR (255) NOT NULL,
    nome_colecao VARCHAR (255) NOT NULL,
	passagem DATE NOT NULL,
	footprint GEOMETRY NOT NULL CHECK(ST_GeometryType(footprint) = 'ST_Polygon' OR
                                      ST_GeometryType(footprint) = 'ST_MultiPolygon')
);

INSERT INTO cena (colecao_id, nome_cena, nome_colecao, passagem, footprint)
    VALUES ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', 'CBERS-4_16D_000003_2020-12-18_2020-12-31', 'CBERS-4-16D', '2020-12-18',  ST_GeometryFromText('POLYGON(( -72.02 -9.08, -71.78 -5.31, -75.61 -5.05, -75.91 -8.81, -72.02 -9.08 ))', 4326)),
           ('869783c7-c0b7-4cd9-b141-83a8a0e3ec04', 'AMZ-1_8D_000002_2023-01-01_2023-01-16', 'AMAZONIA-1-8D', '2023-01-01',  ST_GeometryFromText('POLYGON(( -71.78 -5.31, -71.54 1.52, -75.32 1.25, -75.61 5.05, -71.78 -5.31 ))', 4326));


-- TODO: checar --
CREATE TABLE timeline(
	colecao_id UUID  REFERENCES colecao(id)
                                    ON DELETE NO ACTION
                                    ON UPDATE CASCADE,
	instante DATE NOT NULL,
    PRIMARY KEY (colecao_id, instante)
);

INSERT INTO timeline (colecao_id, instante)
    VALUES ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', '2020-12-18'),
           ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', '2021-12-18'),
           ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', '2022-12-18')
           ('869783c7-c0b7-4cd9-b141-83a8a0e3ec04', '2023-01-01');

-- --

CREATE OR REPLACE FUNCTION AtualizaColecao()
RETURNS trigger
AS
$$
DECLARE
    query text;
    newdate DATERANGE DEFAULT NULL;
    gunion GEOMETRY DEFAULT NULL;

    col colecao%ROWTYPE; -- ou: RECORD
BEGIN
    query := 'UPDATE colecao';
    IF TG_OP = 'INSERT' THEN
        SELECT * INTO col FROM colecao WHERE nome = NEW.nome_colecao;
        RAISE NOTICE 'col: %', col;
        -- Does the period contain passagem? --
        IF NOT col.periodo @> NEW.passagem THEN
            IF NEW.passagem < lower(col.periodo) THEN
                newdate := format('[%s, %s)', NEW.passagem, upper(col.periodo));
            ELSE 
                newdate := format('[%s, %s)', lower(col.periodo), NEW.passagem);
            END IF;
            query := query || format(' SET periodo = ''%s''', newdate);
            RAISE NOTICE 'newdate: %', newdate;
            RAISE NOTICE 'query 1: %', query;
        END IF;
        -- Does the cobetura contains footprint? --
        IF NOT ST_Contains(col.cobertura, NEW.footprint) THEN
            gunion := ST_Union(col.cobertura, NEW.footprint);
            query := query || format(', cobertura = ''%s'' ', ST_AsText(gunion));
        END IF;
        query := query || format(' WHERE nome = ''%s''; ', NEW.nome_colecao);
        RAISE NOTICE 'query 2: %', query;
        IF newdate IS NOT NULL OR gunion IS NOT NULL THEN
            RAISE NOTICE 'entrou aqui';
            EXECUTE query;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualiza_colecao3
  AFTER INSERT OR UPDATE
  ON cena
  FOR EACH ROW EXECUTE PROCEDURE AtualizaColecao();

INSERT INTO cena (colecao_id, nome_cena, nome_colecao, passagem, footprint)
    VALUES ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', 'CBERS-4_16D_002004_2016-01-01_2016-01-16', 'CBERS-4-16D', '2016-01-01',  ST_GeometryFromText('POLYGON(( -64.38 -13.22, -64.24 -9.46, -68.13 -9.30, -68.33 -13.06, -64.38 -13.22 ))', 4326));

SELECT AtualizaColecao('CBERS-4-16D');

-- --

CREATE OR REPLACE FUNCTION AtualizaTimeline()
RETURNS trigger
AS
$$
DECLARE
    query text;
    tl timeline%ROWTYPE;
BEGIN
    query := 'INSERT INTO timeline (colecao_id, instante)';
    IF TG_OP = 'INSERT' THEN
        SELECT * INTO tl FROM timeline WHERE instante = NEW.passagem AND 
            colecao_id = NEW.colecao_id;
        -- Does the instante was found? --
        IF NOT FOUND THEN
            query := query || format(
                ' VALUES (''%s'', ''%s'');', NEW.colecao_id, NEW.passagem
            );
            RAISE NOTICE 'query: %', query;
            EXECUTE query;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualiza_timeline
  AFTER INSERT OR UPDATE
  ON cena
  FOR EACH ROW EXECUTE PROCEDURE AtualizaTimeline();

INSERT INTO cena (colecao_id, nome_cena, nome_colecao, passagem, footprint)
    VALUES ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', 'CBERS-4_16D_002004_2013-01-01_2013-01-16', 'CBERS-4-16D', '2013-01-01',  ST_GeometryFromText('POLYGON(( -64.38 -13.22, -64.24 -9.46, -68.13 -9.30, -68.33 -13.06, -64.38 -13.22 ))', 4326));