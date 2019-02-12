WITH turn(turno_id) AS (
  VALUES(5)
  )
  ,salario AS (
    SELECT
    t_s.valor_salario
    ,t.id_ruta
    ,t.id_turno
    ,t_s.salario_id
    ,t.hora_salida
    ,ct.bea_neto_total
          ,CASE
            WHEN t_s.valor_salario >= 1
              THEN t_s.valor_salario
              else ct.bea_neto_total * t_s.valor_salario
      END AS pago_conductor

      FROM turn tn
      INNER JOIN turno t
        ON tn.turno_id = t.id_turno
      INNER JOIN ruta r
	      ON t.id_ruta = r.id_ruta
      INNER JOIN salario t_s
        ON r.salario_id = t_s.salario_id
	    INNER JOIN costo_turno ct
	      ON t.id_turno = ct.id_turno
     WHERE TRUE
     AND ct.vehiculo = t.vehiculo
      ORDER BY t.id_turno, t.hora_salida DESC LIMIT 1
    )
    SELECT
    s.valor_salario
    ,s.salario_id
    ,s.hora_salida
    ,s.id_ruta
    ,s.id_turno
    ,s.bea_neto_total
    ,pago_conductor
    FROM salario s;
