CREATE OR REPLACE FUNCTION turns(num_vehiculo INT, ruta INT,num_turno INT, salida TIME, mensaje VARCHAR(50) DEFAULT 'Sin novedad') RETURNS VOID AS $$
DECLARE

/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar turno
 * statement in PostgreSQL.
 */

numturno INT;
nombre_ruta varchar(30);
BEGIN
-- CREATE TYPE estado AS ENUM ('Pendiente','Transito','Terminado')

INSERT INTO
  turnos( vehiculo, id_ruta, numero_turno, rodamiento_id, hora_salida, mensaje)
    SELECT
      num_vehiculo
      ,ruta
      ,num_turno
      ,r_ct.id_rodamiento
      ,salida
      ,mensaje
    FROM vehiculos v_r
      INNER JOIN rodamientos r_ct
        ON v_r.numero_interno = r_ct.numero_interno
    WHERE TRUE
    AND v_r.numero_interno = num_vehiculo
    ORDER BY  r_ct.id_rodamiento DESC limit 1;
END;
$$ LANGUAGE plpgsql VOLATILE;

---------------------------------tiempos de marcada--------------------------------------------

CREATE OR REPLACE FUNCTION add_turn_time() RETURNS TRIGGER AS $_time$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: trigger tiempo
 * statement in PostgreSQL.
 */

DECLARE

  BEGIN
    IF(TG_OP = 'INSERT') THEN
    INSERT INTO tiempos (
      id_turno
      ,tiempo_max
      ,nombre_marcada
      ,num_vehiculo
    )
    SELECT
      NEW.id_turno
      ,CASE
       WHEN t.hora_salida < t_e.hora
             THEN t.hora_salida + (rr_r.tiempo_max || 'minute')::INTERVAL
       WHEN t.hora_salida >= t_e.hora
            THEN t.hora_salida + (t_e.tiempo_adicional || 'minute')::INTERVAL
       ELSE t.hora_salida + (rr_r.tiempo_max || 'minute')::INTERVAL
       END AS tiempo_max
       ,nombre_reloj
       ,vehiculo
    FROM turnos t
      INNER JOIN rutas r
        ON t.id_ruta = r.id_ruta
      INNER JOIN ruta_relojes rr_r
        ON t.id_ruta = rr_r.id_ruta
      LEFT JOIN tiempo_adicional t_e
        ON t_e.ruta_reloj_id = rr_r.id_ruta_reloj
      INNER JOIN relojes rl
        ON rr_r.id_reloj = rl.id_reloj
    WHERE TRUE
      AND t.id_turno = NEW.id_turno
      ORDER BY rr_r.id_ruta_reloj;
  END IF;
  RETURN NEW;
  END;
  $_time$ LANGUAGE plpgsql;

  CREATE TRIGGER after_insert_turn
  AFTER INSERT ON turnos
  FOR EACH ROW
  EXECUTE PROCEDURE add_turn_time();

  -------------------------marcadas------------------------------------
CREATE OR REPLACE FUNCTION marked(idtiempo INT,time_marked TIME) RETURNS VOID AS $marcada$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar tiempos
 * statement in PostgreSQL.
 */

DECLARE
    tiempomax TIME;
  BEGIN
  tiempomax:=(SELECT tiempo_max FROM tiempos WHERE id_tiempo = idtiempo);

  UPDATE tiempos SET tiempo_marcada = time_marked
    WHERE id_tiempo = idtiempo;
  UPDATE tiempos SET  numero_caida =  (SELECT EXTRACT( MINUTE FROM tiempo_marcada - tiempo_max ))
      WHERE id_tiempo = idtiempo;
  END;
  $marcada$ LANGUAGE plpgsql;
  -----------------------INSERTAR VALORES TURNOS-------------------------
CREATE OR REPLACE FUNCTION update_turns(passenger INT,auxiliary INT,positive INT,bloking INT,speed INT,bea DOUBLE PRECISION, vehicle INT) RETURNS VOID AS $update_turn$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Costo ruta
 * statement in PostgreSQL.
 */
DECLARE
BEGIN
WITH updated_turns (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto, vehiculo)
AS(
VALUES
  (passenger, auxiliary, positive, bloking, speed, bea, vehicle)
),updated_at AS(

UPDATE turnos SET
    pasajero = passenger
    ,auxiliar =auxiliary
    ,positivo = positive
    ,bloqueo = bloking
    ,velocidad = speed
    ,bea_bruto = bea
    ,vehiculo = vehicle
    RETURNING id_turno
)
SELECT * FROM turnos WHERE id_turno IN (SELECT id_turno FROM updated_at );
END;
$update_turn$ LANGUAGE plpgsql VOLATILE;


------------------------------- costo_turno--------------------------------------------------
CREATE OR REPLACE FUNCTION trigg_shift_cost() RETURNS TRIGGER AS $costo_turno$
  /*
   * Author: Jhonny Stiven Agudelo Tenorio
   * Purpose: Costo ruta
   * statement in PostgreSQL.
   */
  DECLARE

  BEGIN
  IF(TG_OP = 'UPDATE') THEN
  INSERT INTO costo_turnos (
    id_turno
    ,costo_positivo
    ,bea_neto
    -- ,bea_neto_total
    ,vehiculo
    ,numero_turno
    )
    SELECT
     NEW.id_turno

     ,CASE
        WHEN r_t.tarifa_positivo_id = t_rt.tarifa_positivo_id THEN
        (CASE WHEN t.positivo >= t_rt.num_positivo
            THEN (t.positivo * t_rt.valor_ruta) * t_rt.costo
          ELSE 0 END ) END AS costo_positivo

     ,CASE WHEN r_t.id_ayuda = aa_v.id_ayuda THEN t.bea_bruto - aa_v.precio ELSE bea_bruto END AS bea_neto

     -- ,bea_neto_total = (bea_neto + costo_positivo)::DOUBLE PRECISION

     ,t.vehiculo
     ,t.numero_turno
    FROM turnos t
    INNER JOIN rutas r_t
      ON t.id_ruta = r_t.id_ruta
    LEFT JOIN ayuda_auxiliar aa_v
      ON  r_t.id_ayuda = aa_v.id_ayuda
    LEFT JOIN  tarifa_positivos t_rt
      ON r_t.tarifa_positivo_id =  t_rt.tarifa_positivo_id
    WHERE TRUE
    AND t.id_turno = NEW.id_turno;
  END IF;
  RETURN NEW;
  END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER after_cost_turn
  AFTER UPDATE ON turnos
  FOR EACH ROW
  EXECUTE PROCEDURE trigg_shift_cost();

-----------------------------------------gasto_turno--------------------------------------------------------


/*si actualiza el precio no cambia el resultado de pago condictor*/


CREATE OR REPLACE FUNCTION trigg_shift_expense() RETURNS TRIGGER AS $gasto_turno$
  /*
   * Author: Jhonny Stiven Agudelo Tenorio
   * Purpose: Costo ruta
   * statement in PostgreSQL.
   */
BEGIN
  IF(TG_OP='INSERT') THEN
    INSERT INTO gasto_turnos(
      id_turno
      ,num_turno
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

      ,COALESCE(p_r.precio_peaje, 0) AS peaje

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
          INNER JOIN costo_turnos ct_t
            ON  t.id_turno = ct_t.id_turno
          INNER JOIN rodamientos rr_t
            ON t.rodamiento_id = rr_t.id_rodamiento
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
          LEFT JOIN peajes p_r
            ON r.peaje_id = p_r.id_peaje
WHERE TRUE
    AND t.id_turno = NEW.id_turno
ORDER BY t.id_turno DESC LIMIT 1;
END IF;
RETURN NEW;

IF(TG_OP = 'UPDATE') THEN
  UPDATE gasto_turno
END IF;
RETURN NEW;
END;
$gasto_turno$ LANGUAGE plpgsql VOLATILE;


 CREATE TRIGGER insert_gasto_turn
 AFTER INSERT ON costo_turnos
 FOR EACH ROW
 EXECUTE PROCEDURE trigg_shift_expense();

 CREATE TRIGGER updated_gasto_turn
 AFTER UPDATE ON costo_turnos
 FOR EACH ROW
 WHEN (OLD.pago_conductor IS DISTINCT FROM NEW.pago_conductor)
 EXECUTE PROCEDURE trigg_shift_expense();

 ---------------------------------------liquidacion_turno-------------------------------------------------
CREATE OR REPLACE FUNCTION payment_turn() RETURNS TRIGGER AS $liquidacion_turno$
  /*
   * Author: Jhonny Stiven Agudelo Tenorio
   * Purpose: Costo ruta
   * statement in PostgreSQL.
   */
BEGIN
IF(TG_OP='INSERT') THEN
  INSERT INTO recaudo_turnos(
    ,id_turno
    ,num_turno
    ,valor_total
    ,valor_bea
    ,peaje
    ,otros
    ,descuento
    ,combustible
    ,bloqueos
    ,exentos
    ,velocidad
    ,pago_conductor
    ,descripcion
    ,pasajero
    ,conduce
    ,liquidar
    ,saldo_asociado
    ,bonificacion
    )
    SELECT
    NEW.id_turno
    ,t.numero_turno
    ,COALESCE(
            t_ct.bea_neto + t_ct.costo_positivo, 0
      )AS valor_total
    ,t_ct.bea_neto
    ,t_gt.peaje
    ,t_gt.otros
    ,t_gt.descuento
    ,t_gt.combustible
    ,t.bloqueo
    ,t.auxiliar
    ,t.velocidad
    ,t_gt.pago_conductor
    ,t_gt.descripcion
    ,t.pasajeros
    ,t_gt.conduce
    ,ROUND(t_gt.bea_neto -(COALESCE(t_ct.peaje, 0) +
      COALESCE(t_ct.otros, 0) +
      COALESCE(t_ct.descuento, 0) +
      COALESCE(t_ct.pago_conductor, 0) +
      COALESCE(t_ct.conduce, 0))) AS liquidar
    ,


































INSERT INTO turnos (id_turno,pasajero, auxiliar,vehiculo)
  VALUES (1, 37,1,7118)
    ON CONFLICT (id_turno) DO UPDATE
      SET pasajero = 37,
      auxiliar = 1,
      vehiculo = 7118;







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
          COALESCE(t_ct.conduce, 0))) AS liquidar
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
      GROUP BY t_ct.id_turno
      ,t_gt.id_turno
      ,ts.id_turno,
      r.nombre
      ,ts.vehiculo
      ,t_gt.bea_neto
      ,t_ct.peaje
      ,t_ct.otros
      ,t_ct.descuento
      ,t_ct.pago_conductor
      ,t_ct.conduce
      ORDER BY t_gt.id_turno DESC LIMIT 1
    )
  SELECT
  p.vehiculo
  ,p.id_turno
  ,p.nombre
  ,p.bea_neto
  ,p.liquidar
  ,p.peaje
  ,p.otros
  ,p.descuento
  ,p.pago_conductor
  ,p.conduce
  FROM prueba p;