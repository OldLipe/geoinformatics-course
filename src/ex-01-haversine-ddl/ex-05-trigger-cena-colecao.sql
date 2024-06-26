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
    VALUES ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', 'CBERS-4_16D_002004_2016-01-01_2016-01-16', 'CBERS-4-16D', '2016-01-01',  
    ST_GeometryFromText('POLYGON(( -64.38 -13.22, -64.24 -9.46, -68.13 -9.30, -68.33 -13.06, -64.38 -13.22 ))', 4326));