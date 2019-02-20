CREATE OR REPLACE FUNCTION deduction (transfer DOUBLE PRECISION, aforista DOUBLE PRECISION, otro DOUBLE PRECISION, mensaje VARCHAR DEFAULT 'Sin novedad') RETURNS VOID AS $gasto_turno$
BEGIN

UPDATE gasto_turno
SET
transbordo = transfer
,pasaje_aforista = aforista
,otros = otro
,descripcion = mensaje
WHERE

RAISE NOTICE 'INGRESARON LOS DATOS CON EXITOS';
END;
$gasto_turno$ LANGUAGE PLPGSQL VOLATILE;



