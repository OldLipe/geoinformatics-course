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