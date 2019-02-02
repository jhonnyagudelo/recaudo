WITH turn(turno_id) AS (
  VALUES(1)
  )
  ,salario AS (
    SELECT
    t_s.valor_pago
    ,t.id_ruta
    ,t.id_turno
    ,ct.bea_neto_total
    ,CASE
     WHEN r.salario_id = t_s.salario_id
        THEN ct.bea_neto_total * t_s.valor_pago
      WHEN t.id_ruta = 3 OR t.id_ruta = 4  OR t.id_ruta = 15 OR t.id_ruta = 16
        THEN r.salario_id
      ELSE 0
      END AS pago_conductor
      FROM turn tn
      INNER JOIN turno t
        ON tn.turno_id = t.id_turno
      INNER JOIN ruta r
	ON t.id_ruta = r.id_ruta
      INNER JOIN salario t_s
        ON r.salario_id = t_s.salario_id
	INNER JOIN costo_turno ct
	ON t.id_turno = ct.id_costo_turno
     WHERE TRUE
      ORDER BY t.id_turno
    )
    SELECT
    s.valor_pago
    ,s.id_ruta
    ,s.id_turno
    ,s.bea_neto_total
    ,pago_conductor
    FROM salario s;
