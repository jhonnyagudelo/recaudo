WITH turn(turno_id) AS (
  VALUES(2)
  )
,consulta AS(
  SELECT
    t.id_turno
    ,t.numero_turno
    ,tp.nombre_marcada
    ,t.hora_salida
    ,tp.tiempo_max
    ,tp.tiempo_marcada
    ,tp.numero_caida
    ,t.vehiculo
    ,SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)
            OVER(
              PARTITION BY tp.id_turno
              ) AS total_caida

    ,CASE
        WHEN tp.nombre_marcada = 'Antonio Nariño'
          THEN tp.numero_caida * 0
        WHEN tp.nombre_marcada = 'Rio Cauca'
          THEN tp.numero_caida * 0
        WHEN tp.numero_caida >=1
          THEN tp.numero_caida * 5000
      ELSE 0 END
      AS cancelar

      FROM turn tn
      INNER JOIN turno t
        ON tn.turno_id = t.id_turno
      INNER JOIN tiempo tp
        ON tp.id_turno = t.id_turno
      WHERE TRUE
      ORDER BY tp.tiempo_max
  )
  SELECT
  c.id_turno
  ,c.numero_turno
  ,c.nombre_marcada
  ,c.hora_salida
  ,c.tiempo_max
  ,c.tiempo_marcada
  ,c.numero_caida
  ,c.total_caida
  ,cancelar
  ,SUM(cancelar)OVER( PARTITION BY total_caida ) AS total_cancelar

FROM consulta c;
