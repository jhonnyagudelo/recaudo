
WITH turn(autobus, turno, fecha) AS (
  VALUES(7018,1,'2019-05-28'::DATE )
  )
,data_procesa AS (
  SELECT DISTINCT
       t_p.*
      ,+ CASE
            WHEN TRUE
                AND t_p.numero_caida >= r_rj.min_caida
                    THEN t_p.numero_caida
                ELSE 0
            END AS total_caida

    FROM turn t_n
    INNER JOIN vehiculos v_h
          ON t_n.autobus = v_h.numero_interno
    INNER JOIN rodamientos r_d
          ON v_h.numero_interno = r_d.numero_interno
    INNER JOIN turnos t
          ON t.rodamiento_id = r_d.id_rodamiento
    INNER JOIN rutas r
          ON r.id_ruta = t.id_ruta
    INNER JOIN ruta_relojes r_rj
          ON t.id_ruta = r_rj.id_ruta
    INNER JOIN tiempos t_p
      ON t.id_turno = t_p.id_turno

    WHERE TRUE
    AND t_p.numero_turno = t_n.turno
    AND t.create_at::DATE =t_n.fecha::DATE
    AND t.vehiculo = t_n.autobus
        GROUP BY t_p.id_tiempo
                ,r_rj.id_ruta_reloj
        ORDER BY t_p.tiempo_max
)
,data_cash AS (
    SELECT
        r_d.numero_interno
        -- ,r_d.despacho
        ,t.id_ruta
        ,t_p.num_vehiculo
        ,t_p.nombre_marcada
        ,t_p.numero_caida
        ,SUM(p.total_caida)OVER() AS total_caida
        ,t_p.tiempo_marcada
        ,CASE
                WHEN TRUE
                        AND total_caida >= r_rj.min_caida
                    THEN (
                            CASE
                                WHEN TRUE
                                        AND total_caida > c_a.num_caida
                                    THEN total_caida * c_a.valor_consecutivo
                                ELSE 0
                            END
                        ) * r_rj.valor_caida
                    ELSE 0
                END
        AS pago_caida
    FROM data_procesa p
        INNER JOIN vehiculos v_h
                ON p.num_vehiculo = v_h.numero_interno
          INNER JOIN rodamientos r_d
                ON v_h.numero_interno = r_d.numero_interno
          INNER JOIN turnos t
                ON t.rodamiento_id = r_d.id_rodamiento
          INNER JOIN rutas r
                ON r.id_ruta = t.id_ruta
          INNER JOIN ruta_relojes r_rj
                ON t.id_ruta = r_rj.id_ruta
          LEFT JOIN caidas_consecutivas c_a
                ON c_a.id_ruta_reloj = r_rj.id_ruta_reloj
          INNER JOIN tiempos t_p
                ON t.id_turno = t_p.id_turno
      )

SELECT
  p.num_vehiculo
  ,p.nombre_marcada
  ,p.numero_caida
  ,SUM(p.total_caida)OVER() AS total_caida
  ,p.tiempo_marcada
  ,p.pago_caida
FROM data_cash p;







-----------------------------------------------------------------------------

WITH turn(autobus, turno, fecha) AS (
  VALUES(7018,1,'2019-05-28'::DATE )
  )
,date_procesa AS (
  SELECT DISTINCT
       t_p.id_turno
      ,t_p.numero_turno
      ,t_p.nombre_marcada
      ,t_p.tiempo_max
      ,t_p.tiempo_marcada
      ,t_p.numero_caida
      ,t_p.num_vehiculo
      ,+ CASE
            WHEN TRUE
                AND t_p.numero_caida >= r_rj.min_caida
                    THEN t_p.numero_caida
                ELSE 0
            END AS total_caida
    FROM turn t_n
    INNER JOIN vehiculos v_h
          ON t_n.autobus = v_h.numero_interno
    INNER JOIN rodamientos r_d
          ON v_h.numero_interno = r_d.numero_interno
    INNER JOIN turnos t
          ON t.rodamiento_id = r_d.id_rodamiento
    INNER JOIN rutas r
          ON r.id_ruta = t.id_ruta
    INNER JOIN ruta_relojes r_rj
          ON t.id_ruta = r_rj.id_ruta
    LEFT JOIN caidas_consecutivas c_a
          ON c_a.id_ruta_reloj = r_rj.id_ruta_reloj
    INNER JOIN tiempos t_p
      ON t.id_turno = t_p.id_turno

    WHERE TRUE
    AND t_p.numero_turno = t_n.turno
    AND t.create_at::DATE =t_n.fecha::DATE
    AND t.vehiculo = t_n.autobus
        GROUP BY t_p.id_tiempo
                ,r_rj.id_ruta_reloj
        ORDER BY t_p.tiempo_max
)
,cash AS (
  SELECT DISTINCT
    total_caida

)

SELECT
  p.num_vehiculo
  ,p.nombre_marcada
  ,p.numero_caida
  ,SUM(p.total_caida)OVER() AS total_caida
  ,p.tiempo_marcada
FROM date_procesa p

















---------------------------------


-- ,distinc_caida AS (
--     SELECT
--       t_p.*
--       ,CASE
--         WHEN TRUE
--           AND t_p.numero_caida >= r_rj.min_caida
--             THEN(
--               CASE
--                 WHEN TRUE
--                   AND t_p.numero_caida >= c_a.num_caida
--                     THEN t_p.numero_caida * c_a.valor_consecutivo
--                 ELSE 0
--               END ) * r_rj.valor_caida
--           ELSE 0
--         END AS cancelar_total

--     FROM turn tn
--       INNER JOIN  turnos t
--         ON tn.autobus = t.vehiculo
--     INNER JOIN rutas r
--           ON r.id_ruta = t.id_ruta
--     INNER JOIN ruta_relojes r_rj
--           ON t.id_ruta = r_rj.id_ruta
--     LEFT JOIN caidas_consecutivas c_a
--           ON c_a.id_ruta_reloj = r_rj.id_ruta_reloj
--     INNER JOIN tiempos t_p
--           ON t.id_turno = t_p.id_turno
--       WHERE TRUE
--       ORDER BY t_p.tiempo_max

-- )

,data_marcada AS (
  SELECT
    t.id_turno
    t.vehiculo
    ,t.numero_turno
    ,t.hora_salida
    ,t_p.nombre_marcada
    ,t_p.tiempo_marcada
    ,t_p.numero_caida
  ,CASE
    WHEN TRUE
      AND t_p.numero_caida >= r_rj.min_caida
        THEN(
          CASE
            WHEN TRUE
              AND tp.numero_caida >= c_a.num_caida
                t_p.numero_caida * c_a.valor_consecutivo
            ELSE 0
          END ) * r_rj.valor_caida
      ELSE 0
    END AS cancelar

)




,CASE
    WHEN TRUE
      AND t_p.numero_caida >= r_rj.min_caida
        THEN(
          CASE
            WHEN TRUE
              AND tp.numero_caida >= c_a.num_caida
                THEN t_p.numero_caida * c_a.valor_consecutivo
            ELSE 0
          END ) * r_rj.valor_caida
      ELSE 0
    END AS cancelar_total
-------------------------------------------------------------------------------
WITH turn(autobus, turno, fecha) AS (
  VALUES(6043, 1, '2019-05-15'::DATE )
  )
,suma_caida AS (
  SELECT DISTINCT
       t_p.id_turno
      ,t_p.numero_turno
      ,t_p.nombre_marcada
      ,t_p.tiempo_max
      ,t_p.tiempo_marcada
      ,t_p.numero_caida
      ,t_p.num_vehiculo

    FROM turn t_n
    INNER JOIN vehiculos v_h
          ON t_n.autobus = v_h.numero_interno
    INNER JOIN rodamientos r_d
          ON v_h.numero_interno = r_d.numero_interno
    INNER JOIN turnos t
          ON t.rodamiento_id = r_d.id_rodamiento
    INNER JOIN rutas r
          ON r.id_ruta = t.id_ruta
    INNER JOIN ruta_relojes r_rj
          ON t.id_ruta = r_rj.id_ruta
    LEFT JOIN (
                SELECT
                    drop.numero_caida
                    ,SUM( s_c.numero_caida)OVER() *
      caidas_consecutivas c_a
          ON c_a.id_ruta_reloj = r_rj.id_ruta_reloj
    INNER JOIN tiempos t_p
      ON t.id_turno = t_p.id_turno

    WHERE TRUE
    AND t_p.numero_turno = 1
    AND t.create_at::DATE ='2019-05-15'::DATE
    AND t.vehiculo = 6043
)

SELECT
  s_c.num_vehiculo
  ,s_c.nombre_marcada
  ,s_c.tiempo_marcada
  ,s_c.numero_caida
FROM suma_caida s_c
