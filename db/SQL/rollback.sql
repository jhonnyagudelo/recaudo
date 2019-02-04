CREATE OR REPLACE FUNCTION  spending_shift(pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision,num_vehiculo INT)RETURNS void  AS $costo_turno$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Costo ruta
 * statement in PostgreSQL.
 */

  DECLARE
  /* num_positivo int; */
  costo DOUBLE PRECISION;
  porcentaje double precision;
  ruta_ayuda varchar(20);
  idcostoturno int;
  turno_id INT;
  numero_t INT;
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
  ORDER BY t.hora_salida  DESC limit 1);
  RAISE NOTICE 'El  NUMERO ID %', turno_id;

  /* numero_t:=(
    SELECT
    t.numero_turno
    FROM turno t
    INNER JOIN  costo_turno ct
    ON t.id_turno = ct.id_turno
    WHERE TRUE
    AND CURRENT_DATE::TIMESTAMP <= ct.create_at
    AND t.vehiculo = ct.vehiculo
    ORDER BY t.id_turno DESC limit 1);
    RAISE NOTICE 'El  NUMERO TURNO %', numero_t; */

idcostoturno:=(
  SELECT
  c_t.id_costo_turno
  FROM costo_turno c_t
  INNER JOIN turno t
  ON c_t.vehiculo = t.vehiculo
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= c_t.create_at
  AND c_t.vehiculo = t.vehiculo
ORDER BY t.id_turno  DESC limit 1
);

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


  UPDATE costo_turno SET id_turno = turno_id,
  numero_turno  = (  SELECT
    t.numero_turno
    FROM turno t
    INNER JOIN  costo_turno ct
    ON t.id_turno = ct.id_turno
    WHERE TRUE
    AND CURRENT_DATE::TIMESTAMP <= ct.create_at
    AND t.vehiculo = ct.vehiculo
    ORDER BY t.id_turno DESC limit 1)
  WHERE id_costo_turno = idcostoturno;

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

  auxiliary_help:= (
    SELECT c_a.precio
      FROM costo_turno ct
    INNER JOIN turno t
      ON ct.id_turno = t.id_turno
    INNER JOIN ruta r
      ON r.id_ruta = t.id_ruta
    INNER JOIN ayuda_auxiliar c_a
      ON c_a.id_ayuda = r.id_ayuda
    WHERE TRUE
      AND ct.id_costo_turno = idcostoturno);

    -------------AYUDA AUXILIAR---------------------------
IF( idhelp = 1 OR idhelp = 2) THEN
UPDATE costo_turno SET bea_neto = (bea_bruto - auxiliary_help) WHERE id_costo_turno = idcostoturno;
    RAISE NOTICE 'ayuda_auxiliar %', auxiliary_help;
ELSE
    UPDATE costo_turno SET bea_neto = bea_bruto;
END IF;

  -------------FORMULA PARA ABORDADOS O POSITIVOS-------------------------


    formula:=(positivo * porcentaje) * costo;
          RAISE NOTICE 'el resultado es %', formula;

    IF (positivo >=6) THEN
      UPDATE costo_turno SET costo_positivo = formula,
      bea_neto_total  = (bea_neto + formula)
      WHERE id_costo_turno= idcostoturno;
      ELSE
      UPDATE costo_turno SET bea_neto_total =  bea_neto;
    END IF;

  END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;




SELECT spending_shift(30,0,15,0,97,100000,4001);

select * from costo_turno;



truncate costo_turno restart identity;
select * from costo_turno;
