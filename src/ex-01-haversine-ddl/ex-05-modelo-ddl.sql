-- To reproduce the same UUID for cena table --
SELECT setseed(22);
-- Create and Insert into colecao -- 
CREATE TABLE colecao(
	id UUID PRIMARY KEY,
	nome VARCHAR (255) NOT NULL,
	periodo DATERANGE NOT NULL,
	cobertura GEOMETRY NOT NULL,
    CHECK(ST_GeometryType(cobertura) = 'ST_Polygon' OR
          ST_GeometryType(cobertura) = 'ST_MultiPolygon')
);

INSERT INTO colecao (id, nome, periodo, cobertura)
    VALUES ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', 'CBERS-4-16D', '[2018-01-01, 2023-12-31)',  ST_GeometryFromText('POLYGON(( -67.88 -10.10, -45.33 -10.10, -45.33 -0.36, -67.88 -0.36, -67.88 -10.10 ))', 4326)),
           ('869783c7-c0b7-4cd9-b141-83a8a0e3ec04', 'AMAZONIA-1-8D', '[2023-01-01, 2023-12-31)',  ST_GeometryFromText('POLYGON(( -67.88 -10.10, -45.33 -10.10, -45.33 -0.36, -67.88 -0.36, -67.88 -10.10 ))', 4326));
-- Create and Insert into cena --
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

-- Create and Insert into timeline --
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
           ('c1ed7736-ee29-4709-86e3-7e8d2dfc13e4', '2022-12-18'),
           ('869783c7-c0b7-4cd9-b141-83a8a0e3ec04', '2023-01-01');