CREATE OR REPLACE FUNCTION shift_expense (transfer DOUBLE PRECISION, aforista DOUBLE PRECISION, otro DOUBLE PRECISION, pago_peaje INT) RETURNS VOID AS $gasto_turno$
DECLARE

BEGIN
INSERT INTO gasto_turno (transbordo, pasaje_aforista, otros, peaje)
  VALUES (transfer, aforista, otro, pago_peaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITOS';
$gasto_turno$;
LANGUAGE plpgsql VOLATILE;








CREATE OR REPLACE FUNCTION add_trigg_shift_expense() RETURNS TRIGGER AS $$
DECLARE
BEGIN
 IF(TG_OP = 'UPDATE') THEN
  INSERT INTO gasto_turno(
    id_turno
    ,conduce
    ,pago_conductor
    ,num_turno
    ,vehiculo
    )
    SELECT
    ,ct.id_turno
    ,CASE
        WHEN r.tasa_id = r_t.tasa_id
        THEN  r_t.precio
      ELSE  NULL
      END AS conduce

    ,CASE
      WHEN t_s.valor_salario >= 1
        THEN t_s.valor_salario
        ELSE ct.bea_neto_total * t_s.valor_salario
        END AS pago_conductor
    ,ct.numero_turno
    ,ct.vehiculo
FROM turno t
INNER JOIN ruta r
  ON t.id_ruta = r.id_ruta
INNER JOIN salario t_s
 ON r.salario_id = t_s.salario_id
INNER JOIN tasa r_t
 ON r_t.tasa_id = r.tasa_id
INNER JOIN costo_turno ct
 ON t.id_turno = ct.id_turno

 WHERE TRUE
 AND ct.id_costo_turno = NEW.id_costo_turno
 ORDER BY t.id_turno, t.hora_salida;
 END IF;
 RETURN NEW;
 END;
 $$ LANGUAGE PLPGSQL;

 CREATE  TRIGGER insert_gasto_turn
 AFTER UPDATE ON costo_turno
 FOR EACH ROW
 EXECUTE PROCEDURE add_trigg_shift_expense();
