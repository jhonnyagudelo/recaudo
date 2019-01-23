
CREATE OR REPLACE FUNCTION  spending_shift(pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision)RETURNS void  AS $costo_turno$
  /*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar turno
 * statement in PostgreSQL.
 */

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

  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto,vehiculo)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto,vehiculo);
    RAISE NOTICE 'ingreso valores con exitos';
  BEGIN
    idcostoturno:=(SELECT id_turno
										FROM turno t
											INNER JOIN rodamiento r_t
												ON r_t.id_rodamiento = t.rodamiento
											INNER JOIN vehiculo v_r
												ON r_t.numero_interno = v_r.numero_interno
										WHERE TRUE
											AND CURRENT_DATE::TIMESTAMP <= t.create_at
											AND t.vehiculo = 7118
												ORDER BY r_t.id_rodamiento, r_t.hora_salida DESC limit 1);


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

    UPDATE costo_turno SET numero_turno = (SELECT numero_turno FROM turno
                                            WHERE id_turno =
                                          (SELECT id_turno FROM costo_turno
                                            WHERE id_costo_turno = idcostoturno))
    																				WHERE id_costo_turno = idcostoturno;


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
-----------------------------------------------PRADERA--------------------------------------------
CREATE OR REPLACE VIEW vista_pradera AS
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar turno
 * statement in PostgreSQL.
 */
WITH turn(id_turno) AS (


	VALUES(3)
	)
, data_turno AS (
	SELECT
		t.*
		, coalesce((
						SELECT
						  EXTRACT(MINUTES FROM t.hora_salida - t_1.hora_salida)
						FROM turno t_1
					 	WHERE TRUE
					 		AND CURRENT_DATE::TIMESTAMP <= t_1.create_at
					 		AND t_1.hora_salida < t.hora_salida
					 		AND t_1.id_ruta = t.id_ruta
					 	limit 1
					),7) AS diferencia
	FROM turn tn
		INNER JOIN turno t
			ON t.id_turno = tn.id_turno
)

,consulta AS (
		SELECT
		t.id_turno
		,t.numero_turno
		,tp.nombre_marcada
		,t.hora_salida
		,tp.tiempo_max
		,tp.tiempo_marcada
		,tp.numero_caida
		,t.vehiculo
		,diferencia

		,SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)
						OVER(
							PARTITION BY tp.id_turno
							) AS total_caida

	,CASE
		WHEN tp.numero_caida >= diferencia
			THEN diferencia
				ELSE tp.numero_caida
	END AS min_cancelar


    ,CASE
				WHEN tp.nombre_marcada = 'Albeiro'
  					THEN (CASE
				WHEN tp.numero_caida >= diferencia
						THEN diferencia
				ELSE tp.numero_caida
							END) * 10000

 				WHEN tp.nombre_marcada = 'La Y'
 						THEN (CASE
				WHEN tp.numero_caida >= diferencia
						THEN diferencia
				ELSE tp.numero_caida
							END) * 10000

				WHEN tp.numero_caida >=1
					THEN (CASE
				WHEN tp.numero_caida >= diferencia
						THEN diferencia
				ELSE tp.numero_caida
						END) * 5000
				ELSE 0
		END AS cancelar

		FROM data_turno t
		INNER JOIN tiempo tp
			ON tp.id_turno = t.id_turno
		INNER JOIN turn tn
			 ON tp.id_turno = tn.id_turno

		WHERE TRUE
		ORDER BY tp.tiempo_max
		)


,vehicle_next AS(
	SELECT
			t.vehiculo
		FROM turno t
			INNER JOIN rodamiento r_t
				ON r_t.id_rodamiento = t.rodamiento
			INNER JOIN vehiculo v_r
				ON r_t.numero_interno = v_r.numero_interno
		WHERE TRUE
		AND r_t.numero_interno > 4000
	 ORDER BY r_t.id_rodamiento, r_t.numero_interno asc limit 1
	)


		SELECT
		c.id_turno
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
----------------------------------------------------COSTARICA--------------------------------------------------------
PP