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
    NEW.id_turno
    ,CASE
          WHEN r.tasa_id = r_t.tasa_id
            THEN  r_t.precio
        END AS conduce

    ,CASE
      WHEN s_r.valor_salario >= 1
        THEN s_r.valor_salario
        ELSE ct_t.bea_neto_total * s_r.valor_salario
      END AS pago_conductor
    ,ct_t.numero_turno
    ,ct_t.vehiculo

FROM turno t
INNER JOIN vehiculo v_t
  ON t.vehiculo = v_t.numero_interno
INNER JOIN ruta r
  ON t.id_ruta = r.id_ruta
INNER JOIN salario s_r
  ON  r.salario_id = s_r.salario_id
LEFT JOIN tasa r_t
  ON r.tasa_id = r_t.tasa_id
INNER JOIN costo_turno ct_t
    ON t.id_turno = ct_t.id_turno

 WHERE TRUE
 AND t.id_turno = NEW.id_turno
 AND t.numero_turno = ct_t.numero_turno
 AND ct_t.vehiculo = v_t.numero_interno
 ORDER BY t.id_turno;
 END IF;
 RETURN NEW;
 END;
 $$ LANGUAGE PLPGSQL VOLATILE;

 CREATE  TRIGGER insert_gasto_turn
 AFTER UPDATE ON costo_turno
 FOR EACH ROW
 EXECUTE PROCEDURE add_trigg_shift_expense();
