WITH turn(turno_id) AS (
  values(1)
  )
  ,hola AS (
  SELECT
  t.id_turno
  ,CASE
        WHEN r.tasa_id = r_t.tasa_id
          THEN  r_t.precio
      END AS conduce
  ,CASE
        WHEN r.descuento_id = r_d.descuento_id
          THEN  r_d.precio_unico
      END AS descuento

  ,CASE
    WHEN s_r.valor_salario >= 1
      THEN s_r.valor_salario
      ELSE ct.bea_neto * s_r.valor_salario
    END AS pago_conductor

  ,CASE
    WHEN r.combustible_id = r_c.combustible_id
      THEN ROUND(r.kilometros / v_t.consumo_galon::decimal(4,2)) * r_c.precio_galon
    ELSE 0
    END AS combustible

  ,ct.numero_turno
  ,ct.vehiculo
  ,r_c.precio_galon
  ,v_t.consumo_galon
  ,r.kilometros


FROM turno t
INNER JOIN vehiculo v_t
ON t.vehiculo = v_t.numero_interno
INNER JOIN rodamiento rr_t
ON v_t.numero_interno = rr_t.numero_interno
INNER JOIN ruta r
ON t.id_ruta = r.id_ruta
INNER JOIN salario s_r
ON  r.salario_id = s_r.salario_id
LEFT JOIN tasa r_t
ON r.tasa_id = r_t.tasa_id
LEFT JOIN descuento r_d
ON r.descuento_id = r_d.descuento_id
INNER JOIN combustible r_c
ON r_c.combustible_id = r.combustible_id
INNER JOIN costo_turno ct
  ON t.id_turno = ct.id_turno
WHERE TRUE
AND ct.id_turno = t.id_turno
ORDER BY ct.id_turno
)
SELECT
h.id_turno
,h.pago_conductor
,h.numero_turno
,h.conduce
,h.descuento
,h.precio_galon
,h.kilometros
,h.consumo_galon
,h.combustible
,h.vehiculo
FROM hola h;
