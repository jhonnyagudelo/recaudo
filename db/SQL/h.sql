WITH turn(turno_id) AS (
  values(1)
  )
  ,hola AS (
  SELECT
  t.id_turno
  ,CASE
        WHEN r.tasa_id = r_t.tasa_id
          THEN  r_t.precio
        ELSE 0
      END AS conduce
  ,CASE
        WHEN r.descuento_id = r_d.descuento_id
          THEN  r_d.precio_unico
          ELSE 0
      END AS descuento

  ,CASE
    WHEN s_r.valor_salario >= 1
      THEN s_r.valor_salario
      ELSE ct.bea_neto * s_r.valor_salario
    END AS pago_conductor

  ,CASE
    WHEN r.combustible_id = r_c.combustible_id
      THEN ROUND(r.kilometros / v_t.consumo_galon::double precision) * r_c.precio_galon
    ELSE 0
    END AS combustible

    ,CASE
      WHEN r.peaje_id = p_r.id_peaje
        THEN p_r.precio_peaje
      ELSE 0
      END AS peaje

  ,ct.numero_turno
  ,ct.vehiculo
  ,r_c.precio_galon
  ,v_t.consumo_galon
  ,r.kilometros


FROM turn tn
INNER JOIN turno t
ON t.id_turno = turno_id
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
LEFT JOIN peaje p_r
        ON r.peaje_id = p_r.id_peaje
INNER JOIN combustible r_c
ON r_c.combustible_id = r.combustible_id

INNER JOIN costo_turno ct
  ON t.id_turno = ct.id_turno
WHERE TRUE
ORDER BY ct.id_turno
)
,suma_gasto AS (
  SELECT
    h.*
    ,((
      h.pago_conductor
      + h.conduce
      + h.descuento
      + h.peaje) + COALESCE(ct_h.bea_neto,0)
      ) AS liquidar

    FROM hola h
      INNER JOIN gasto_turno gt_h
        ON h.id_turno = gt_h.gasto_id
      INNER JOIN costo_turno ct_h
        ON ct_h.id_turno = gt_h.id_turno
      WHERE TRUE
      AND h.id_turno = ct_h.id_turno
      AND h.numero_turno = gt_h.num_turno
      GROUP BY h.id_turno, h.pago_conductor, h.conduce, h.descuento,
      h.combustible,h.peaje
        ,h.numero_turno
  ,h.vehiculo
  ,h.precio_galon
  ,h.consumo_galon
  ,h.kilometros
  ,ct_h.bea_neto

  )

SELECT
sg.id_turno
,sg.pago_conductor
,sg.numero_turno
,sg.conduce
,sg.descuento
,sg.peaje
,sg.vehiculo
,liquidar
FROM suma_gasto sg;
-----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_collection() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    INSERT INTO recaudo_turno(
        id_turno
        ,num_turno
        ,fecha_rodamiento
        ,hora_despacho
        ,valor_total
        ,peaje
        ,otros
        ,descuento
        ,combustible
        ,despacho
        ,saldo_asociado
        ,bloqueos
        ,exentos
        ,velocidad
        ,pago_conductor
        ,descripcion
        ,pasajeros
        ,conduce
        ,liquidar
      )
    SELECT
    NEW.id_turno



    FROM turno
    INNER JOIN






