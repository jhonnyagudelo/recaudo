CREATE OR REPLACE FUNCTION add_turn_time() RETURNS TRIGGER AS $_time$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: trigger tiempo
 * statement in PostgreSQL.
 */

DECLARE
  horario_salida TIME;
  numturno INT;
  bus INT;
  BEGIN
  numturno:=(SELECT MAX(id_turno)FROM turno);
  bus:=(SELECT vehiculo FROM turno WHERE id_turno = numturno);
  horario_salida:=(SELECT hora_salida FROM turno WHERE id_turno = numturno);

    IF(TG_OP = 'UPDATE') THEN
    INSERT INTO tiempo (
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
    FROM turno t
      INNER JOIN ruta r
        ON t.id_ruta = r.id_ruta
      INNER JOIN ruta_reloj rr_r
        ON t.id_ruta = rr_r.id_ruta
      LEFT JOIN tiempo_extra t_e
        ON t_e.ruta_reloj_id = rr_r.id_ruta_reloj
      INNER JOIN reloj rl
        ON rr_r.id_reloj = rl.id_reloj
    WHERE TRUE
      AND t.id_turno = NEW.id_turno
      ORDER BY rr_r.id_ruta_reloj;
  END IF;
  RETURN NEW;
  END;
  $_time$ LANGUAGE plpgsql;
