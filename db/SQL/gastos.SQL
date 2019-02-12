CREATE OR REPLACE FUNCTION shift_expense (transfer DOUBLE PRECISION, aforista DOUBLE PRECISION, otro DOUBLE PRECISION, pago_peaje INT) RETURNS VOID AS $gasto_turno$
DECLARE

BEGIN
INSERT INTO gasto_turno (transbordo, pasaje_aforista, otros, peaje)
  VALUES (transfer, aforista, otro, pago_peaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITOS';
$gasto_turno$;
LANGUAGE plpgsql VOLATILE;
