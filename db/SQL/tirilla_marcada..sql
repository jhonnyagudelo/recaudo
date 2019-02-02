next_bus:=(SELECT vehiculo  FROM turno WHERE id_turno = 3+1);

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


maxi candelaria = 70.000
buga 50.000;
costa rica 70.0001
