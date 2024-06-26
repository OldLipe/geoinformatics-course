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