CREATE OR REPLACE FUNCTION trigg_shift_expense() RETURNS TRIGGER AS $gasto_turno$
  /*
   * Author: Jhonny Stiven Agudelo Tenorio
   * Purpose: Costo ruta
   * statement in PostgreSQL.
   */
BEGIN
  IF(TG_OP='UPDATE') THEN
    INSERT INTO gasto_turno(
      id_turno
      ,numero_turno
      ,peaje
      ,pago_conductor
      ,descuento
      ,conduce
      ,combustible
      ,vehiculo
      )
      SELECT
      NEW.id_turno
      ,t.numero_turno
      ,COALESCE(p_r.precio_peaje_id, 0) AS peaje
      ,CASE WHEN s_r.valor_salario >= 1
        THEN s_r.valor_salario
          ELSE ct_t.bea_neto * s_r.valor_salario
      END AS pago_conductor
      ,COALESCE(r_d.precio_unico, 0) AS descuento
      ,COALESCE(r_t.precio, 0) AS conduce
      ,CASE WHEN r.combustible_id = r_c.combustible_id
        THEN ROUND(r.kilometros / v_t.consumo_galon::double precision) * r_c.precio_galon
          ELSE 0
      END AS combustible
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
          INNER JOIN ct_t.bea_neto
            ON  t.id_turno = ct_t.id_turno
WHERE TRUE
AND t.id_turno = NEW.id_turno
ORDER BY t.id_turno;
END IF;
RETURN NEW;
END;
$gasto_turno$ LANGUAGE plpgsql VOLATILE;


 CREATE TRIGGER insert_gasto_turn
 AFTER UPDATE ON costo_turno
 FOR EACH ROW
 EXECUTE PROCEDURE trigg_shift_expense();












  WITH gasto(id_gasto) AS (
    values (6)
    )
  ,prueba AS (
    SELECT
    ts.id_turno
    ,r.nombre
    ,ts.vehiculo
    ,t_gt.bea_neto
    ,ROUND(t_gt.bea_neto -(COALESCE(t_ct.peaje, 0) +
          COALESCE(t_ct.otros, 0) +
          COALESCE(t_ct.descuento, 0) +
          COALESCE(t_ct.pago_conductor, 0) +
          COALESCE(t_ct.conduce, 0)
          )) AS gasto
    -- ,COALESCE((gasto - t_gt.bea_neto) ,0 ) AS liquidar
    ,t_ct.peaje
    ,t_ct.otros
    ,t_ct.descuento
    ,t_ct.pago_conductor
    ,t_ct.conduce
    FROM gasto g
      INNER JOIN gasto_turnos t_ct
        ON g.id_gasto = t_ct.gasto_id
      INNER JOIN costo_turnos t_gt
        ON t_ct.id_turno = t_gt.id_turno
      INNER JOIN turnos ts
        ON ts.id_turno = t_ct.id_turno
      INNER JOIN rutas r
        ON ts.id_ruta = r.id_ruta
      WHERE TRUE

      ORDER BY t_gt.id_turno DESC LIMIT 1
    )
  SELECT
  p.vehiculo
  ,p.id_turno
  ,p.nombre
  ,p.bea_neto
  ,SUM(gasto) OVER(PARTITION BY id_turno) AS descuento
  ,p.peaje
  ,p.otros
  ,p.descuento
  ,p.pago_conductor
  ,p.conduce
  FROM prueba p;