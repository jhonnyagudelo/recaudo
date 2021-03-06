CREATE OR REPLACE FUNCTION  cost_turn (pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision,num_vehiculo INT)RETURNS void  AS $costo_turno$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Costo ruta
 * statement in PostgreSQL.
 */

  DECLARE
  /* num_positivo int; */
  costo DOUBLE PRECISION;
  porcentaje double precision;
  idcostoturno int;
  turno_id INT;
  idruta INT;
  idhelp INT;
  auxiliary_help DOUBLE PRECISION;
  formula DOUBLE PRECISION;
  BEGIN
  ----- INSERT
IF EXISTS(
  SELECT v_c.numero_interno
  FROM vehiculo v_c
    INNER JOIN rodamiento v_r
      ON v_c.numero_interno = v_r.numero_interno
    INNER JOIN turno t
      ON t.vehiculo = v_r.numero_interno
  WHERE TRUE
  AND v_c.numero_interno = num_vehiculo
  ORDER BY id_rodamiento DESC LIMIT 1
  ) THEN
  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, vehiculo)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, num_vehiculo);
  ELSE
    RAISE NOTICE 'EL VEHICULO NO EXISTE, INGRESELO AL SISTEMA ';
  END IF;

  --------------------------------------- JOIN VARIABLES-------------------------------
  /* INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, vehiculo)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto,
        (SELECT num_vehiculo
          FROM vehiculo v_r
            INNER JOIN rodamiento r_ct
              ON v_r.numero_interno = r_ct.numero_interno
            INNER JOIN turno r_t
              ON r_t.rodamiento = r_ct.id_rodamiento
            INNER JOIN ruta rr_t
              ON rr_t.id_ruta = r_t.id_ruta
          WHERE TRUE
          AND r_ct.numero_interno = num_vehiculo));

          COMMIT; */


idcostoturno:=(
  SELECT
  c_t.id_costo_turno
  FROM costo_turno c_t
  INNER JOIN turno t
  ON  t.vehiculo = num_vehiculo
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= c_t.create_at
ORDER BY c_t.id_turno  DESC limit 1
);


----------------------UPDATE TURNO Y NUMERO TURNO
UPDATE costo_turno SET id_turno = (
  SELECT
    t.id_turno
  FROM turno t
    INNER JOIN costo_turno c_t
    ON c_t.vehiculo = t.vehiculo
  WHERE TRUE
    /* AND CURRENT_DATE::TIMESTAMP <= t.create_at */
    AND t.vehiculo = num_vehiculo
  ORDER BY t.id_turno DESC limit 1) WHERE id_costo_turno = idcostoturno;

UPDATE costo_turno SET numero_turno  = (
   SELECT
  t.numero_turno
  FROM turno t
 INNER JOIN  costo_turno ct
  ON t.id_turno = ct.id_turno
  WHERE TRUE
  /* AND CURRENT_DATE::TIMESTAMP <= ct.create_at */
   AND t.vehiculo =  num_vehiculo
  ORDER BY t.id_turno, t.hora_salida DESC LIMIT 1 )
WHERE id_costo_turno = idcostoturno;



porcentaje:=(
  SELECT
    tt_t.valor_ruta
  FROM turno t
  INNER JOIN ruta r
    ON t.id_ruta = r.id_ruta
  INNER JOIN tarifa_positivo tt_t
    ON tt_t.tarifa_positivo_id = r.tarifa_positivo_id
  WHERE TRUE
    AND t.id_ruta = r.id_ruta
    AND t.vehiculo = num_vehiculo
    ORDER BY t.id_turno LIMIT 1 );
  RAISE NOTICE 'El porcentaje es %', porcentaje;

costo:=(SELECT
      tt_t.costo
      FROM turno t
      INNER JOIN ruta r
        ON t.id_ruta = r.id_ruta
      INNER JOIN tarifa_positivo tt_t
        ON tt_t.tarifa_positivo_id = r.tarifa_positivo_id
      WHERE TRUE
          AND t.id_ruta = r.id_ruta
          AND t.vehiculo = num_vehiculo
          ORDER BY t.id_turno LIMIT 1);
RAISE NOTICE 'El  costo por positivo es %', costo;

  idruta:=(
    SELECT
    r.id_ayuda
    FROM ruta r
    INNER JOIN turno t_r
      ON r.id_ruta = t_r.id_ruta
    INNER JOIN costo_turno t_c
      ON t_r.id_turno = t_c.id_turno
    WHERE TRUE
      AND t_r.vehiculo = num_vehiculo
    ORDER BY  t_r.id_turno, t_r.hora_salida DESC limit 1);

  idhelp:=(
    SELECT
      r_aa.id_ayuda
    FROM costo_turno t_ct
    INNER JOIN turno r_t
      ON r_t.id_turno = t_ct.id_turno
    INNER JOIN ruta r
      ON r.id_ruta = r_t.id_ruta
    INNER JOIN ayuda_auxiliar r_aa
      ON r.id_ayuda = r_aa.id_ayuda
    WHERE TRUE
    AND  t_ct.vehiculo = r_t.vehiculo
    ORDER BY t_ct.vehiculo DESC LIMIT 1 );

  auxiliary_help:= (
    SELECT
      r_aa.precio
    FROM costo_turno t_ct
    INNER JOIN turno r_t
      ON r_t.id_turno = t_ct.id_turno
    INNER JOIN ruta r
      ON r.id_ruta = r_t.id_ruta
    INNER JOIN ayuda_auxiliar r_aa
      ON r.id_ayuda = r_aa.id_ayuda
    WHERE TRUE
    AND  t_ct.vehiculo = r_t.vehiculo
    ORDER BY t_ct.vehiculo DESC LIMIT 1);

-----------------------------------------UPDATE ----------------------------------------------------------------------------
  --------------AYUDA AUXILIAR---------------------------
  IF (idruta = idhelp)
   THEN
    UPDATE costo_turno SET bea_neto = (bea_bruto - auxiliary_help) WHERE id_costo_turno = idcostoturno;
    RAISE NOTICE 'ayuda_auxiliar %', auxiliary_help;
  ELSE
  UPDATE costo_turno SET bea_neto =  bea_bruto   WHERE id_costo_turno = idcostoturno;
  END IF;

  -------------FORMULA PARA ABORDADOS O POSITIVOS-------------------------

    formula:=(positivo * porcentaje) * costo;
          RAISE NOTICE 'el resultado es %', formula;

    IF (positivo >=6) THEN
      UPDATE costo_turno SET costo_positivo = formula,
      bea_neto_total  = (bea_neto + formula)
      WHERE id_costo_turno= idcostoturno;
      ELSE
      UPDATE costo_turno SET bea_neto_total =  bea_neto WHERE id_costo_turno= idcostoturno;
    END IF;
    END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;


truncate costo_turno restart identity;


SELECT cost_turn(30,0,15,0,97,100000,7118);
truncate costo_turno restart identity;




select * from costo_turno;
