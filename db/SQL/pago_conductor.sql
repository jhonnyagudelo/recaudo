WITH turn(turno_id) AS (
  VALUES(1)
  )
  ,salario AS (
    SELECT
    t_s.valor_salario
    ,t.id_ruta
    ,t.id_turno
    ,t_s.salario_id
    ,t.hora_salida
    ,ct.bea_neto
               ,SUM(CASE
                  WHEN r.tarifa_positivo_id = t_rt.tarifa_positivo_id THEN
                    (CASE
                     WHEN t.positivo >= t_rt.num_positivo
                      THEN (t.positivo * t_rt.valor_ruta) * t_rt.costo
                      ELSE 0 END)
                    WHEN r.id_ayuda = aa_v.id_ayuda
                      THEN t.bea_bruto - aa_v.precio ELSE bea_bruto END) OVER (PARTITION BY  t.id_turno) AS bea_neto_total
          ,CASE
            WHEN t_s.salario_id = r.salario_id
              THEN ct.bea_neto * t_s.valor_salario
      END AS pago_conductor

      FROM turn tn
      INNER JOIN turnos t
        ON tn.turno_id = t.id_turno
      INNER JOIN rutas r
	      ON t.id_ruta = r.id_ruta
      INNER JOIN salarios t_s
        ON r.salario_id = t_s.salario_id
	    INNER JOIN costo_turnos ct
	      ON t.id_turno = ct.id_turno
       LEFT JOIN ayuda_auxiliar aa_v
              ON  r.id_ayuda = aa_v.id_ayuda
      LEFT JOIN  tarifa_positivos t_rt
              ON r.tarifa_positivo_id =  t_rt.tarifa_positivo_id
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
