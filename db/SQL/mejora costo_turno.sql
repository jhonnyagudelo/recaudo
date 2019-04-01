
    SELECT

     , 35 AS pasajeros
     , 0 AS auxiliares
     , 8 AS positivos
     , 0 AS bloqueos
     , 97 AS velocidad
     , 120000 AS bea_bruto
     , r_t.id_turno AS id_turno
     , 0 AS costo_positivo
     , 0 AS bea_neto_total
     , 0 AS bea_neto
     , v_r AS vehiculo
     , t_r AS numero_turno
          -- v_r.numero_interno
          -- ,r_ct.id_rodamiento
          -- ,r_t.id_turno
          FROM vehiculo v_r
            INNER JOIN rodamiento r_ct
              ON v_r.numero_interno = r_ct.numero_interno
            INNER JOIN turno r_t
               ON r_t.rodamiento = r_ct.id_rodamiento
          WHERE TRUE
          AND v_r.numero_interno = 7118
          AND r_ct.id_rodamiento = 1
          AND r_t.id_turno = 2
          ;




  INSERT INTO turnos
    ()
  SELECT
    num_vehiculo, ruta,num_turno,salida
  FROM turnos t
  INNER JOIN rodamientos r_t
    ON r_t.id_rodamiento = t.rodamiento_id
  WHERE TRUE
    AND CURRENT_DATE::TIMESTAMP <= t.create_at
    AND t.vehiculo = num_vehiculo;



INSERT INTO
  turnos( vehiculo, id_ruta, numero_turno, hora_salida, mensaje)
    SELECT
      7118
      ,1
      ,1
      ,r.id_rodamiento
      ,'6:00'
    FROM rodamientos r
      WHERE TRUE
        AND r.numero_interno = num_vehiculo;




SELECT
.numero_interno
,v_rt.placa
,s_rt.valor_salario* 85000 AS pago_conductor
,r_r.nombre
,aa_v.precio
,CASE
        WHEN r_r.tarifa_positivo_id = tp_r.tarifa_positivo_id THEN
        (CASE WHEN t_rt.positivo >= tp_r.num_positivo
            THEN (t_rt.positivo * tp_r.valor_ruta) * tp_r.costo
              ELSE 0 END ) END AS positivo
-- ,CASE WHEN t_rt.auxiliar =aa_v.id_ayuda THEN bea_bruto-aa_v.precio
,ts_t.precio
,dc_r.precio_unico
FROM rodamientos rt
  INNER JOIN vehiculos v_rt
    ON rt.numero_interno = v_rt.numero_interno
  INNER JOIN turnos t_rt
    ON t_rt.rodamiento_id = rt.id_rodamiento
  INNER JOIN rutas r_r
    ON  r_r.id_ruta = t_rt.id_ruta
  INNER JOIN salarios s_rt
    ON s_rt.salario_id = r_r.salario_id
  LEFT JOIN ayuda_auxiliar aa_v
    ON aa_v.id_ayuda = r_r.id_ayuda
  LEFT JOIN tarifa_positivos tp_r
    ON tp_r.tarifa_positivo_id = r_r.tarifa_positivo_id
  LEFT JOIN tasa ts_t
    ON ts_t.tasa_id = r_r.tasa_id
  LEFT JOIN descuentos dc_r
    ON dc_r.descuento_id = r_r.descuento_id;





SELECT
t.vehiculo
,r_t.nombre
,t_rt.valor_ruta

,CASE
        WHEN r_t.tarifa_positivo_id = t_rt.tarifa_positivo_id THEN
        (CASE WHEN t.positivo >= t_rt.num_positivo
            THEN (t.positivo * t_rt.valor_ruta) * t_rt.costo
              ELSE 0 END ) END AS costo_positivo
     ,CASE WHEN r_t.id_ayuda = aa_v.id_ayuda THEN t.bea_bruto - aa_v.precio ELSE bea_bruto END AS bea_neto
     ,bea_neto_total = (t_ct.bea_neto + t_ct.costo_positivo)::DOUBLE PRECISION
     ,t.vehiculo
     ,t.numero_turno
    FROM turnos t
    INNER JOIN rutas r_t
      ON t.id_ruta = r_t.id_ruta
    LEFT JOIN ayuda_auxiliar aa_v
      ON  r_t.id_ayuda = aa_v.id_ayuda
    LEFT JOIN  tarifa_positivos t_rt
      ON r_t.tarifa_positivo_id =  t_rt.tarifa_positivo_id
    INNER JOIN costo_turnos t_ct
      ON t.id_turno = t_ct.id_turno








WITH upsert AS
(UPDATE spider_count
  SET tally=1
    WHERE date='today'
      RETURNING *)
  INSERT INTO
    spider_count (spider, tally)
      SELECT 'Googlebot', 1
        WHERE NOT EXISTS (SELECT * FROM upsert)



INSERT INTO turnos(
  pasajero
  ,auxiliar
  ,positivo
  ,bloqueo
  ,velocidad
  ,bea_bruto

)
VALUES (
  32
  ,1
  ,6
  ,1
  ,97
  ,102000
);

RETURNING *;










    WITH update_turns (pasajero, auxiliar, positivo, bloqueo, velocidad, bea_bruto, vehiculo)
      AS(
        VALUES
            (37, 1, 6, 1, 97, 102000, 7118)
        )
          ,updated_at AS(
            UPDATE turnos
              SET pasajero = 37
              ,auxiliar =1
              ,positivo = 6
              ,bloqueo = 1
              ,velocidad = 97
              ,bea_bruto = 10000
              ,vehiculo = 7118
            FROM update_turns u_ts
              INNER JOIN turnos t
                ON u_ts.vehiculo = t.vehiculo
              WHERE TRUE
              AND CURRENT_DATE::TIMESTAMP <= t.create_at
              RETURNING  u_ts.*
              )
              INSERT INTO turnos (pasajero, auxiliar, positivo, bloqueo, velocidad, bea_bruto, vehiculo)
                 SELECT (37, 1, 4, 1, 97, 102000, 7118)
                  FROM updated_turns
                  WHERE NOT EXISTS
                  (SELECT 7118
                      FROM updated_at u_at
                        INNER JOIN update_turns u_ts
                        ON u_at.vehiculo = u_ts.vehiculo
                      );









    WITH updated_turns (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto, vehiculo)
      AS(
        VALUES
            (passenger, auxiliary, positive, bloking, speed, bea, vehicle)
        )
          ,updated_at AS(
            UPDATE turnos SET
              pasajero = passenger
              ,auxiliar =auxiliary
              ,positivo = positive
              ,bloqueo = bloking
              ,velocidad = speed
              ,bea_bruto = bea
              ,vehiculo = vehicle
              )
            FROM updated_turns u_ts
              INNER JOIN turnos t
                ON u_ts.vehicle = t.vehiculo
              INNER JOIN rodamiento t_rt
                ON t.vehiculo = t_rt.numero_interno
              WHERE TRUE
              AND CURRENT_DATE::TIMESTAMP <= t.create_at
              AND t_rt.numero_interno = vehicle
              AND
              RETURNING turnos *

          -- INSERT INTO turnos (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto, vehiculo)









    WITH updated_turns (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto, vehiculo)
      AS(
        VALUES
            (passenger, auxiliary, positive, bloking, speed, bea, vehicle)
        )
          ,updated_at AS(

         UPDATE turnos SET
              pasajero = passenger
              ,auxiliar =auxiliary
              ,positivo = positive
              ,bloqueo = bloking
              ,velocidad = speed
              ,bea_bruto = bea
              ,vehiculo = vehicle
              FROM
              RETURNING turnos *

              )
            FROM updated_turns u_ts
              INNER JOIN turnos t
                ON u_ts.vehicle = t.vehiculo
              INNER JOIN rodamiento t_rt
                ON t.vehiculo = t_rt.numero_interno
              WHERE TRUE
              AND CURRENT_DATE::TIMESTAMP <= t.create_at
              AND t_rt.numero_interno = vehicle
              AND









    WITH updated_turns (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto, vehiculo)
      AS(
        VALUES
            (passenger, auxiliary, positive, bloking, speed, bea, vehicle)
        ),updated_at AS(

         UPDATE turnos SET
              pasajero = passenger
              ,auxiliar =auxiliary
              ,positivo = positive
              ,bloqueo = bloking
              ,velocidad = speed
              ,bea_bruto = bea
              ,vehiculo = vehicle
              RETURNING turnos *
          )
        SELECT * FROM turnos WHERE id IN (SELECT id_turno FROM updated_at );


      WITH updated_turns (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto, vehiculo)
      AS(
        VALUES
            (37, 1, 6, 0, 97, 102000, 7118)
        ),updated_at AS(

         UPDATE turnos SET
              pasajero = 37
              ,auxiliar =1
              ,positivo = 0
              ,bloqueo = 0
              ,velocidad = 97
              ,bea_bruto = 150000
              ,vehiculo = 7118
              FROM vehiculos v_r
                INNER JOIN rodamientos r_ct
                  ON v_r.numero_interno = r_ct.numero_interno
              WHERE TRUE
              AND v_r.numero_interno = 4001
              RETURNING id_turno;

          )
        SELECT * FROM turnos WHERE id_turno IN (SELECT id_turno FROM updated_at
        WHERE TRUE
        AND vehiculo = 7118
        AND id_turno = 2);



WITH updated AS (UPDATE test SET description = 'test' RETURNING id)
SELECT * FROM test WHERE id IN (SELECT id FROM updated);




UPDATE products SET price = price * 1.10
  WHERE price <= 99.99
  RETURNING name, price AS new_price;


  UPDATE turnos SET bea_bruto = 166000
    WHERE id_turno = 1
    RETURNING numero_turno,pasajero;


UPDATE costo_turnos
        SET bea_neto = bea_bruto
      FROM turnos t
      INNER JOIN rodamientos r_t
        ON t.rodamiento_id = r_t.id_rodamiento
      WHERE TRUE
      AND t.id_turno = OLD.id_turno;
      RAISE NOTICE  'ACTUALICE % ', OLD.id_turno;



WITH update_turns  (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto, vehiculo) AS (
  VALUES ()
)