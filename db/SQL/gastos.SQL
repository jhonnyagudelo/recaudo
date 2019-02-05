CREATE OR REPLACE FUNCTION shift_expense (transfer DOUBLE PRECISION, aforista DOUBLE PRECISION, otro DOUBLE PRECISION, pago_peaje INT) RETURNS VOID AS $gasto_turno$
DECLARE

BEGIN
INSERT INTO gasto_turno (transbordo, pasaje_aforista, otros, peaje)
  VALUES (transfer, aforista, otro, pago_peaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITOS';
$gasto_turno$;
LANGUAGE plpgsql VOLATILE;








CREATE OR REPLACE FUNCTION add_trigg_shift_expense() RETURNS TRIGGER $$
 DECLARE

 BEGIN

 IF(TG = 'INSERT') THEN
  INSERT INTO gasto_turno(
    vehiculo
    ,id_turno
    ,pago_conducto
    ,descuento
    ,num_turno
    )
    SELECT
    NEW.id_turno
