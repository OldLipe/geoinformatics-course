/* 
    @desc Trigger function to update colecao table when a new cena in 
    inserted.
*/
CREATE OR REPLACE FUNCTION AtualizaColecao()
RETURNS trigger
AS
$$
DECLARE
    query text;
    newdate DATERANGE DEFAULT NULL;
    gunion GEOMETRY DEFAULT NULL;
    col colecao%ROWTYPE;
BEGIN
    query := 'UPDATE colecao';
    -- INSERT case --
    IF TG_OP = 'INSERT' THEN
        SELECT * INTO col FROM colecao WHERE nome = NEW.nome_colecao;
        
        -- Does the period contain passagem? --
        IF NOT col.periodo @> NEW.passagem THEN
            IF NEW.passagem < lower(col.periodo) THEN
                newdate := format('[%s, %s)', NEW.passagem, upper(col.periodo));
            ELSE 
                newdate := format('[%s, %s)', lower(col.periodo), NEW.passagem);
            END IF;
            query := query || format(' SET periodo = ''%s''', newdate);
        END IF;

        -- Does the cobetura contains footprint? --
        IF NOT ST_Contains(col.cobertura, NEW.footprint) THEN
            gunion := ST_Union(col.cobertura, NEW.footprint);
            query := query || format(', cobertura = ST_GeometryFromText(''%s'', 4326)', ST_AsText(gunion));
        END IF;
        query := query || format(' WHERE nome = ''%s''; ', NEW.nome_colecao);
        
        -- Are there any value to update?
        IF newdate IS NOT NULL OR gunion IS NOT NULL THEN
            EXECUTE query;
        END IF;
    
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualiza_colecao
  AFTER INSERT OR UPDATE
  ON cena
  FOR EACH ROW EXECUTE PROCEDURE AtualizaColecao();

INSERT INTO cena (colecao_id, nome_cena, nome_colecao, passagem, footprint)
    VALUES ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', 'CBERS-4_16D_002004_2016-01-01_2016-01-16', 'CBERS-4-16D', '2016-01-01',  
    ST_GeometryFromText('POLYGON(( -64.38 -13.22, -64.24 -9.46, -68.13 -9.30, -68.33 -13.06, -64.38 -13.22 ))', 4326));