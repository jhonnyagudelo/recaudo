CREATE OR REPLACE FUNCTION add_trigg_shift_expense() RETURNS TRIGGER AS $$
DECLARE
BEGIN
 IF(TG_OP = 'UPDATE') THEN
  INSERT INTO gasto_turnos(
    id_turno
    ,conduce
    ,descuento
    ,pago_conductor
    ,combustible
    ,peaje
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
       WHEN r.descuento_id = r_d.descuento_id
        THEN  r_d.precio_unico
      END AS descuento

    ,CASE
      WHEN s_r.valor_salario >= 1
       THEN s_r.valor_salario
      ELSE ct_t.bea_neto * s_r.valor_salario
     END AS pago_conductor

     ,CASE
       WHEN r.combustible_id = r_c.combustible_id
        THEN ROUND(r.kilometros / v_t.consumo_galon::double precision) * r_c.precio_galon
       ELSE 0
      END AS combustible

    ,CASE
      WHEN r.peaje_id = p_r.id_peaje
        THEN p_r.precio_peaje
      ELSE 0
      END AS peaje

    ,t.numero_turno
    ,t.vehiculo

    FROM turnos t
    INNER JOIN rodamientos rr_t
        ON t.rodamiento = rr_t.id_rodamiento
    INNER JOIN vehiculos v_t
        ON rr_t.numero_interno = v_t.numero_interno
    INNER JOIN rutas r
        ON t.id_ruta = r.id_ruta
    INNER JOIN salarios s_r
        ON  r.salario_id = s_r.salario_id
    LEFT JOIN tasa r_t
        ON r.tasa_id = r_t.tasa_id
    LEFT JOIN descuentos r_d
        ON r.descuento_id = r_d.descuento_id
    INNER JOIN combustibles r_c
        ON r_c.combustible_id = r.combustible_id
    INNER JOIN peajes p_r
        ON r.peaje_id = p_r.id_peaje

 WHERE TRUE
 AND t.id_turno = NEW.id_turno
 ORDER BY t.id_turno;
 END IF;
 RETURN NEW;
 END;
 $$ LANGUAGE PLPGSQL VOLATILE;

 CREATE TRIGGER insert_gasto_turn
 AFTER UPDATE ON costo_turno
 FOR EACH ROW
 EXECUTE PROCEDURE add_trigg_shift_expense();
