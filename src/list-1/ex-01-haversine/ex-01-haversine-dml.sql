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