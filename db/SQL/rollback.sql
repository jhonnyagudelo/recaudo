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
  turn_help DOUBLE PRECISION;
  formula DOUBLE PRECISION;
  BEGIN
  ----- INSERT

  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, vehiculo)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, num_vehiculo);
    RAISE NOTICE 'ingreso valores con exitos';
--------------------------------------- JOIN VARIABLES-------------------------------
numero_t:=(
  SELECT
  t.numero_turno
  FROM turno t
  INNER JOIN  costo_turno ct
    ON t.vehiculo = ct.vehiculo
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= t.create_at
  AND t.vehiculo = ct.vehiculo
  ORDER BY t.id_turno DESC limit 1);

  RAISE NOTICE 'El  NUEMRO %', numero_t;

turno_id:=  (SELECT id_turno
  FROM turno t
  INNER JOIN rodamiento r_t
  ON r_t.numero_interno = t.vehiculo
  INNER JOIN vehiculo v_r
  ON r_t.numero_interno = v_r.numero_interno
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= t.create_at
  AND t.numero_turno = numero_t
  AND t.vehiculo = vehiculo
ORDER BY r_t.id_rodamiento  DESC limit 1);
  RAISE NOTICE 'El  NUEMRO %', turno_id;

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

idhelp:=(SELECT aa.id_ayuda FROM costo_turno ct
  INNER JOIN turno t
  ON ct.id_turno = t.id_turno
  INNER JOIN ruta r
  ON r.id_ruta = t.id_ruta
  INNER JOIN ayuda_auxiliar aa
  ON aa.id_ayuda = r.id_ayuda
WHERE  ct.id_costo_turno =idcostoturno);

turn_help:= (SELECT aa.precio FROM costo_turno ct
  INNER JOIN turno t
  ON ct.id_turno = t.id_turno
  INNER JOIN ruta r
  ON r.id_ruta = t.id_ruta
  INNER JOIN ayuda_auxiliar aa
  ON aa.id_ayuda = r.id_ayuda
WHERE  ct.id_costo_turno = idcostoturno);


porcentaje:=(SELECT
        tt_t.valor_ruta
        FROM turno t
        INNER JOIN ruta r
          ON t.id_ruta = r.id_ruta
        INNER JOIN tarifa_positivo tt_t
          ON tt_t.tarifa_positivo_id = r.tarifa_positivo_id
        WHERE TRUE
  	        AND t.id_ruta = r.id_ruta
  	        AND t.vehiculo = num_vehiculo);
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
          AND t.vehiculo = num_vehiculo);
RAISE NOTICE 'El  costo por positivo es %', costo;


  UPDATE costo_turno SET numero_turno  = numero_t,
   id_turno = turno_id WHERE id_costo_turno = idcostoturno;
    -------------AYUDA AUXILIAR---------------------------



    IF(idcostoturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
          RAISE NOTICE 'ayuda_auxiliar %', turn_help;
      ELSEIF(idcostoturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
          RAISE NOTICE 'ayuda_auxiliar %', turn_help;
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
      ELSIF (positivo <= 5) THEN
      UPDATE costo_turno SET bea_neto_total =  bea_neto;
    END IF;

  END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;





SELECT spending_shift(30,0,15,0,97,100000,4001);




truncate costo_turno restart identity;
select * from costo_turno;
