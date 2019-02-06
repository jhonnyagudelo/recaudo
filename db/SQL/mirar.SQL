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
SELECT
  id_turno
FROM turno t
  INNER JOIN rodamiento r_t
  ON r_t.numero_interno = t.vehiculo
INNER JOIN vehiculo v_r
  ON r_t.numero_interno = v_r.numero_interno
WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= t.create_at
  AND t.numero_turno = numero_t
  AND t.vehiculo = num_vehiculo
ORDER BY t.hora_salida  DESC limit 1




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
                      ORDER BY r_t.id_rodamiento, t.hora_salida DESC limit 1);
---------------------------------------------------------------------------------------------------------
SELECT numero_turno FROM turno WHERE id_turno =( SELECT id_turno FROM costo_turno WHERE id_costo_turno =1)

SELECT
    tt_t.valor_ruta
  FROM turno t
  INNER JOIN ruta r
    ON t.id_ruta = r.id_ruta
  INNER JOIN tarifa_positivo tt_t
    ON tt_t.tarifa_positivo_id = r.tarifa_positivo_id
  WHERE TRUE
    AND t.id_ruta = r.id_ruta
    AND t.vehiculo = 4001;

SELECT
tt_t.valor_ruta
FROM costo_turno c_t
INNER JOIN turno t
  ON t.id_turno = c_t.id_turno
INNER JOIN ruta r_t
  ON r_t.id_ruta = t.id_ruta
INNER JOIN tarifa_positivo tt_t
 ON tt_t.tarifa_positivo_id = r_t.tarifa_positivo_id
WHERE TRUE
  AND c_t.vehiculo = t.VEHICULO
  AND t.numero_turno = c_t.numero_turno;


--------------------------------------------- ayuda_auxiliar
idhelp:=(
  SELECT aa.id_ayuda
    FROM costo_turno ct
  INNER JOIN turno t
    ON ct.id_turno = t.id_turno
  INNER JOIN ruta r
    ON r.id_ruta = t.id_ruta
  INNER JOIN ayuda_auxiliar aa
    ON aa.id_ayuda = r.id_ayuda
WHERE  ct.id_costo_turno =idcostoturno);

turn_help:= (
  SELECT aa.precio
    FROM costo_turno ct
  INNER JOIN turno t
    ON ct.id_turno = t.id_turno
  INNER JOIN ruta r
    ON r.id_ruta = t.id_ruta
  INNER JOIN ayuda_auxiliar aa
    ON aa.id_ayuda = r.id_ayuda
  WHERE TRUE
    AND ct.id_costo_turno = idcostoturno);

IF(idcostoturno = idhelp) THEN
UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
    RAISE NOTICE 'ayuda_auxiliar %', turn_help;
ELSE
    UPDATE costo_turno SET bea_neto = bea_bruto;
END IF;





UPDATE a
SET price = b_alias.unit_price
FROM      a AS a_alias
LEFT JOIN b AS b_alias ON a_alias.b_fk = b_alias.id
WHERE a_alias.unit_name LIKE 'some_value'
AND a.id = a_alias.id;



SELECT
FROM ruta r
INNER JOIN turno t
 ON t


SELECT
r.id_ayuda
FROM ruta r
INNER JOIN turno t_r
  ON r.id_ruta = t_r.id_ruta
INNER JOIN costo_turno t_c
  ON t_r.id_turno = t_c.id_turno
WHERE TRUE
AND t_r.vehiculo = 7118;


SELECT
  r.id_ayuda, r.id_ruta
FROM costo_turno t_ct
INNER JOIN turno r_t
  ON r_t.id_turno = t_ct.id_turno
INNER JOIN ruta r
  ON r.id_ruta = r_t.id_ruta
WHERE TRUE
AND t_ct.vehiculo = r_t.vehiculo
ORDER BY t_ct.id_costo_turno DESC LIMIT 1;



------------salario_id
SELECT
  s_r.valor_pago, r.id_ruta
FROM costo_turno t_ct
 INNER JOIN turno r_t
   ON r_t.id_turno = t_ct.id_turno
 INNER JOIN ruta r
   ON r.id_ruta = r_t.id_ruta
 INNER JOIN salario s_r
   ON r.salario_id = s_r.salario_id
WHERE TRUE
 AND t_ct.vehiculo  = r_t.vehiculo
ORDER BY t_ct.id_costo_turno ;

SELECT id_turno
                    FROM turno t
                    INNER JOIN rodamiento r_t
                        ON r_t.numero_interno = t.vehiculo
                    INNER JOIN vehiculo v_r
                        ON r_t.numero_interno = v_r.numero_interno
                    WHERE TRUE
                        AND CURRENT_DATE::TIMESTAMP <= t.create_at
                        AND t.vehiculo = num_vehiculo
                        AND t.id_turno > ct_.id_turno
                    ORDER BY t.id_turno limit 1
