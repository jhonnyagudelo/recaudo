WITH turn(turno_id) AS (
  VALUES(7)
  )
  ,tiempo AS (
   SELECT
   t.id_turno
   ,t.vehiculo
   ,t_e.tiempo_adicional
   ,rr_r.tiempo_max
   ,t_e.hora
   ,t.numero_turno
   ,rl.nombre_reloj
   ,t.hora_salida

   ,CASE
      WHEN t.hora_salida < t_e.hora
         THEN  t.hora_salida + (rr_r.tiempo_max  || 'minute')::INTERVAL
      WHEN t.hora_salida >=  t_e.hora
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
           ON t_e.tiempo_max_id = rr_r.id_ruta_reloj
   INNER JOIN reloj rl
          ON rr_r.id_reloj = rl.id_reloj
   WHERE TRUE
   ORDER BY id_ruta_reloj
   )
   SELECT
  c.id_turno
  ,c.vehiculo
  ,c.numero_turno
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

--------------------------------------------------------------------------
WITH rute(ruta_id) AS (
  VALUES(7)
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
  ON t_e.tiempo_max_id = rr_r.id_ruta_reloj
  ------------------------turno de costo turno ----------------
  (SELECT id_turno
                  FROM turno t
                    INNER JOIN rodamiento r_t
                      ON r_t.id_rodamiento = t.rodamiento
                    INNER JOIN vehiculo v_r
                      ON r_t.numero_interno = v_r.numero_interno
                  WHERE TRUE
                    AND CURRENT_DATE::TIMESTAMP <= t.create_at
                    AND t.vehiculo = num_vehiculo
                      ORDER BY r_t.id_rodamiento, r_t.hora_salida DESC limit 1);
---------------------------------------------------------------------------------------------------------
SELECT
t.numero_turno
FROM turno t
INNER JOIN  costo_turno ct
  ON t.vehiculo = ct.vehiculo
WHERE TRUE
AND CURRENT_DATE::TIMESTAMP <= t.create_at
AND numero_turno >= 0




    UPDATE costo_turno SET numero_turno = (SELECT numero_turno FROM turno
                                            WHERE id_turno =
                                              (SELECT id_turno FROM costo_turno
                                                WHERE id_costo_turno = idcostoturno)) WHERE id_costo_turno = idcostoturno;





idcostoturno:=  (SELECT id_turno
                    FROM turno t
                    INNER JOIN rodamiento r_t
                        ON r_t.numero_interno = t.vehiculo
                    INNER JOIN vehiculo v_r
                        ON r_t.numero_interno = v_r.numero_interno
                    WHERE TRUE
                        AND CURRENT_DATE::TIMESTAMP <= t.create_at
                        AND t.vehiculo = num_vehiculo
                    ORDER BY r_t.id_rodamiento,t.hora_salida  DESC limit 1);
