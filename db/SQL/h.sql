WITH turn(turno_id) AS (
  values(2)
  )
  ,hola AS (
  SELECT
  t.id_turno
  ,CASE
      WHEN r.tasa_id = r_t.tasa_id
        THEN  r_t.precio
    END AS conduce
   ,CASE
    WHEN sr.valor_salario >= 1
      THEN sr.valor_salario
      ELSE round( ct.bea_neto_total * sr.valor_salario)
    END AS pago_conductor
  ,ct.numero_turno
  ,ct.vehiculo
FROM turn tn
INNER JOIN costo_turno ct
  ON tn.turno_id = ct.id_costo_turno
INNER JOIN turno t
  ON t.id_turno = ct.id_turno
INNER JOIN ruta r
  ON t.id_ruta = r.id_ruta
INNER JOIN salario sr
  ON r.salario_id = sr.salario_id
LEFT JOIN tasa r_t
  ON r_t.tasa_id = r.tasa_id
WHERE TRUE
AND ct.id_turno = t.id_turno
ORDER BY ct.id_turno
)
SELECT
h.id_turno
,h.pago_conductor
,h.numero_turno
,h.conduce
,h.vehiculo
FROM hola h;
