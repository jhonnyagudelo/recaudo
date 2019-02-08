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

  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, vehiculo)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, num_vehiculo);
    RAISE NOTICE 'ingreso valores con exitos';
--------------------------------------- JOIN VARIABLES-------------------------------


turno_id:=(
  SELECT
    t.id_turno
  FROM turno t
    INNER JOIN costo_turno c_t
    ON c_t.vehiculo = t.vehiculo
  WHERE TRUE
    AND CURRENT_DATE::TIMESTAMP <= t.create_at
    AND t.vehiculo = num_vehiculo
  ORDER BY t.id_turno, t.hora_salida DESC limit 1);
  RAISE NOTICE 'El  NUMERO ID %', turno_id;


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

/* IF(num_vehiculo = 4000) THEN
SELECT numero_interno FROM rodamiento WHERE numero_interno IN
  (SELECT vehiculo FROM costo_turno WHERE id_turno = turno_id);
  RAISE NOTICE 'El VEHICULO EXISTE %', vehiculo;

  ELSE
   RAISE EXCEPTION 'EL VEHICULO NO EXISTE: % ', vehiculo
   USING HINT = 'EL VEHICULO INGRESADO NO EXISTE EN LA BD POR FAVOR VERIFICAR',
   DETAIL = 'EL VEHICULO NO ESTA REGISTRADO INGRESELO EN EL RODAMIENTO O NO EXISTE EN LA BD ';
END IF; */
----------------------UPDATE TURNO Y NUMERO TURNO
UPDATE costo_turno SET id_turno = turno_id  WHERE id_costo_turno = idcostoturno;

UPDATE costo_turno SET numero_turno  = (
   SELECT
  t.numero_turno
  FROM turno t
 INNER JOIN  costo_turno ct
  ON t.id_turno = ct.id_turno
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= ct.create_at
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




SELECT spending_shift(30,0,15,0,97,100000,7118);

select * from costo_turno;



truncate costo_turno restart identity;
select * from costo_turno;
