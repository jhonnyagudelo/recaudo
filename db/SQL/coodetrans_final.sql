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
CREATE OR REPLACE FUNCTION update_values_turns(passenger INT,auxiliary INT,positive INT,bloking INT,speed INT,bea DOUBLE PRECISION, vehicle INT) RETURNS VOID AS $update_turn$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Costo ruta
 * statement in PostgreSQL.
 */
DECLARE
BEGIN


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
CREATE OR REPLACE FUNCTION trigg_shift_expense() RETURNS TRIGGER $gasto_turno$
  /*
   * Author: Jhonny Stiven Agudelo Tenorio
   * Purpose: Costo ruta
   * statement in PostgreSQL.
   */
BEGIN
  IF(TG_OP='UPDATE')
    INSERT INTO gasto_turno(

      )













INSERT INTO turnos (id_turno,pasajero, auxiliar,vehiculo)
  VALUES (1, 37,1,7118)
    ON CONFLICT (id_turno) DO UPDATE
      SET pasajero = 37,
      auxiliar = 1,
      vehiculo = 7118;