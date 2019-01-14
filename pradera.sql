
CREATE OR REPLACE FUNCTION  spending_shift(pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision,idturno int)RETURNS void  AS $costo_turno$
  DECLARE
  num_positivo int;
  costo DOUBLE PRECISION;
  porcentaje double precision;
  ruta_ayuda varchar(20);
  idcostoturno int;
  num_vehiculo int;
  turno INT;
  idhelp INT;
  turn_help DOUBLE PRECISION;
  formula DOUBLE PRECISION;
  BEGIN
  ----- INSERT

  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, id_turno)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, idturno);
    RAISE NOTICE 'ingreso valores con exitos';
  BEGIN
    idcostoturno:=(SELECT MAX(id_costo_turno)FROM costo_turno);

    num_vehiculo:=( SELECT numero_interno FROM rodamiento
                      WHERE id_rodamiento =
                        (SELECT rodamiento FROM turno
                            WHERE id_turno =
                              (SELECT id_turno FROM costo_turno
                                  WHERE id_costo_turno = idcostoturno)));
    idhelp:=(SELECT aa.id_ayuda FROM costo_turno ct
                    INNER JOIN turno t
                      ON ct.id_turno = t.id_turno
                    INNER JOIN ruta r
                      ON r.id_ruta = t.id_ruta
                    INNER JOIN ayuda_auxiliar aa
                      ON aa.id_ayuda = r.id_ayuda WHERE  ct.id_costo_turno =idcostoturno);

    turn_help:= (SELECT aa.precio FROM costo_turno ct
                    INNER JOIN turno t
                      ON ct.id_turno = t.id_turno
                    INNER JOIN ruta r
                      ON r.id_ruta = t.id_ruta
                    INNER JOIN ayuda_auxiliar aa
                      ON aa.id_ayuda = r.id_ayuda WHERE  ct.id_costo_turno = idcostoturno);
    --------INSERT VEHICULO--------------

    UPDATE costo_turno SET vehiculo = (SELECT numero_interno FROM rodamiento
                                        WHERE id_rodamiento =
                                          (SELECT rodamiento FROM turno
                                              WHERE id_turno =
                                                (SELECT id_turno FROM costo_turno
                                                    WHERE id_costo_turno = idcostoturno))),
                          numero_turno = (SELECT numero_turno FROM turno
                                            WHERE id_turno =
                                              (SELECT id_turno FROM costo_turno
                                                WHERE id_costo_turno = idcostoturno)) where id_costo_turno = idcostoturno;

      RAISE NOTICE 'El vehiculo es %', num_vehiculo;
      -- RAISE NOTICE 'El numero del turno es %', numero_turno;

    -------------AYUDA AUXILIAR---------------------------

    IF(idturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
            RAISE NOTICE 'ayuda_auxiliar %', turn_help;
      ELSEIF(idturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
          RAISE NOTICE 'ayuda_auxiliar %', turn_help;
      ELSE
          UPDATE costo_turno SET bea_neto = bea_bruto;
      END IF;
  -------------FORMULA PARA ABORDADOS O POSITIVOS-------------------------
    porcentaje:=(SELECT tv.valor_ruta FROM costo_turno cr
                  INNER JOIN turno t
                    ON cr.id_turno = t.id_turno
                  INNER JOIN ruta r
                    ON r.id_ruta = t.id_ruta
                  INNER JOIN tabla_valor tv
                    ON tv.id_valor = r.id_tabla_valor WHERE cr.id_costo_turno  = idcostoturno);
      RAISE NOTICE 'El porcentaje es %', porcentaje;

    costo:=(SELECT tv.costo FROM costo_turno cr
                INNER JOIN turno t
                  ON cr.id_turno = t.id_turno
                INNER JOIN ruta r
                  ON r.id_ruta = t.id_ruta
                INNER JOIN tabla_valor tv
                  ON tv.id_valor = r.id_tabla_valor WHERE cr.id_costo_turno  = idcostoturno);
      RAISE NOTICE 'El  costo por positivo es %', costo;

    num_positivo:=(SELECT positivos FROM costo_turno WHERE id_costo_turno = idcostoturno);
          RAISE NOTICE 'nuemro positivo es %', num_positivo;

    formula:=(num_positivo * porcentaje) * costo;
          RAISE NOTICE 'el resultado es %', formula;


    IF (num_positivo >=6) THEN
      UPDATE costo_turno SET costo_positivo = formula,
      bea_neto_total  = (bea_neto + formula)
      WHERE id_costo_turno= idcostoturno;
      ELSIF (num_positivo <= 5) THEN
      UPDATE costo_turno SET bea_neto_total =  bea_neto;
    END IF;
  END;
  END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;

--------------------------------------------------------------------------------------------------



WITH turn(id_turno) AS (
	VALUES(1)
	)
	,consulta AS (
		SELECT
		c.id_turno
		,t.numero_turno
		,tp.nombre_marcada
		,t.hora_salida
		,tp.tiempo_max
		,tp.tiempo_marcada
		,tp.numero_caida
		,t.vehiculo

		,SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)
						OVER(
							PARTITION BY tp.id_turno
							) AS total_caida
    ,CASE
				WHEN tp.nombre_marcada = 'Albeiro'
  					THEN tp.numero_caida * 10000
 				WHEN tp.nombre_marcada = 'La Y'
 						THEN tp.numero_caida * 10000
				WHEN tp.numero_caida >=1
					THEN numero_caida * 5000
				ELSE 0
				END AS cancelar

		FROM turn c
		INNER JOIN tiempo tp
			ON tp.id_turno = c.id_turno
			INNER JOIN turno t
			ON t.id_turno = tp.id_turno
		WHERE TRUE
			ORDER BY tp.tiempo_max
		)

	SELECT
	c.id_turno
	,c.vehiculo
	,c.numero_turno
	,c.nombre_marcada
	,c.hora_salida
	,c.tiempo_max
	,c.tiempo_marcada
	,c.numero_caida
	,c.total_caida
	,cancelar
	,SUM(cancelar)OVER( PARTITION BY total_caida ) AS total_cancelar
	,vehiculo
	FROM consulta c;


--------------------------------------------------------------------------------------------------------------v
