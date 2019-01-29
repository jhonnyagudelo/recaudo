WITH turn(turno_id) AS (
  VALUES(4)
  )
  ,tiempo AS (
   SELECT
   t.id_turno
   ,t.vehiculo
   ,t_e.tiempo_adicional
   ,rr_r.tiempo_max
   ,t_e.hora
   ,rl.nombre_reloj
   ,t.hora_salida

   ,CASE
   WHEN t.hora_salida < t_e.hora ---'17:00:00'::TIME
     THEN  t.hora_salida + (rr_r.tiempo_max  || 'minute')::INTERVAL
   WHEN t.hora_salida >=  t_e.hora ---'17:00:00'::TIME ---t_e.hora
    THEN t.hora_salida + (t_e.tiempo_adicional || 'minute')::INTERVAL
        ELSE  t.hora_salida + (rr_r.tiempo_max  || 'minute')::INTERVAL
  END AS tiempo_maxi

  FROM turn tn
   INNER JOIN turno t
          ON tn.turno_id = id_turno
   INNER JOIN ruta r
           ON t.id_ruta = r.id_ruta
   INNER JOIN ruta_reloj rr_r
           ON rr_r.id_ruta = r.id_ruta
   LEFT OUTER JOIN tiempo_extra t_e
          ON t_e.ruta_reloj_id = rr_r.id_ruta_reloj
   INNER JOIN reloj rl
          ON rr_r.id_reloj = rl.id_reloj
   WHERE TRUE
   ORDER BY id_ruta_reloj
   )
   SELECT
  c.id_turno
  ,c.vehiculo
  ,c.tiempo_max
  ,c.tiempo_adicional
  ,c.hora_salida
  ,c.hora
  ,c.nombre_reloj
  ,tiempo_maxi
  FROM tiempo c;

------------------------revisar------------------------


SELECT id_turno
FROM turno t
  INNER JOIN rodamiento r_t
    ON r_t.numero_interno = t.vehiculo
  INNER JOIN vehiculo v_r
    ON r_t.numero_interno = v_r.numero_interno
WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= t.create_at
  AND t.vehiculo = 7118
  AND numero_turno =11
    ORDER BY r_t.id_rodamiento, r_t.hora_salida DESC limit 1;



SELECT
  t.id_rodamiento
FROM turno r_t
INNER JOIN rodamiento t
	ON t.numero_interno = r_t.vehiculo
WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP < r_t.create_at
  AND r_t.create_at > t.create_at
  AND r_t.numero_turno = num_turno
ORDER BY  t.id_rodamiento;


(rr_r.tiempo_max || 'minute')::INTERVAL

---con vehiculo
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
       ,horario_salida +  (rr_r.tiempo_max || 'minute')::INTERVAL
       ,nombre_reloj
       ,vehiculo
    FROM turno t
      INNER JOIN ruta r
        ON t.id_ruta = r.id_ruta
      INNER JOIN ruta_reloj rr_r
        ON r.id_ruta = rr_r.id_ruta
       INNER JOIN reloj rl
        ON rr_r.id_reloj = rl.id_reloj
    WHERE TRUE
      AND t.id_turno = NEW.id_turno
      ORDER BY rr_r.id_ruta_reloj
    ;
  END IF;
  RETURN NEW;
  END;
  $_time$ LANGUAGE plpgsql;
--------------------------------------------------------------------------
WITH rute(ruta_id) AS (
  VALUES(4)
  )
SELECT
rr_r.id_ruta_reloj
,rr_r.tiempo_max
,t_e.ruta_reloj_id
, t_e.tiempo_adicional
FROM rute re
INNER JOIN ruta r
  ON re.ruta_id = r.id_ruta
INNER JOIN ruta_reloj rr_r
  ON rr_r.id_ruta = r.id_ruta
LEFT OUTER JOIN tiempo_extra t_e
  ON id_ruta_reloj = t_e.ruta_reloj_id
