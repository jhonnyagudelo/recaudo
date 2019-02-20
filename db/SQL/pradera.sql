-------------------------------------------------------------------------------------------------------------------------------PRADERA--------------------------------------------
CREATE OR REPLACE VIEW vista_pradera (id_turno)AS
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: mostrar tirilla de marcada
 * statement in PostgreSQL.
 */
WITH turn(id_turno) AS (


	VALUES(1)
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
				WHEN tp.nombre_marcada = 'Albeiro'    /*hacer busqueda por like*/
  					THEN
							(CASE
								WHEN tp.numero_caida >=1
									THEN tp.numero_caida ELSE 0
								END)*10000
					WHEN tp.nombre_marcada = 'Albeiro'
							THEN
								(CASE
									WHEN tp.numero_caida >= diferencia
										THEN diferencia
										ELSE tp.numero_caida
								END) * 10000

				WHEN tp.nombre_marcada = 'La Y'
						THEN
							(CASE
								WHEN tp.numero_caida >=1
									THEN tp.numero_caida ELSE 0
								END)*10000
 				WHEN tp.nombre_marcada = 'La Y'
 						THEN
							(CASE
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

FROM consulta c;
----------------------------------------------------COSTARICA-------------------------------------------------------
