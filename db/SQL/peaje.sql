WITH turn(turno_id,toll_id) AS (
  VALUES (1,4)
  )
  ,precio AS (
    SELECT
    p.id_peaje,
    p.nombre_peaje,
    p.precio_peaje
    FROM turn tp
    INNER JOIN turno t_p
      ON tp.turno_id = t_p.id_turno
    INNER JOIN peaje p
      ON tp.toll_id = p.id_peaje
    INNER JOIN peaje_ruta pr_r
      ON t_p.id_ruta = pr_r.ruta_id
    INNER JOIN costo_turno ct_t
      ON t_p.id_turno = ct_t.id_turno
    WHERE TRUE
    AND t_p.vehiculo = ct_t.vehiculo
    ORDER BY t_p.id_turno LIMIT 1
    )
SELECT
pc.precio_peaje
FROM precio pc;
