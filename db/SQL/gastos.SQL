CREATE OR REPLACE FUNCTION deduction (transfer DOUBLE PRECISION, aforista DOUBLE PRECISION, otro DOUBLE PRECISION, pago_peaje INT) RETURNS VOID AS $gasto_turno$
DECLARE

BEGIN


UPDATE gasto_turno SET transbordo = transfer
,pasaje_aforista = aforista
,otros = otro
,peaje = pago_peaje
WHERE TRUE

RAISE NOTICE 'INGRESARON LOS DATOS CON EXITOS';
$gasto_turno$;
LANGUAGE plpgsql VOLATILE;
