next_bus:=(SELECT vehiculo  FROM turno WHERE id_turno = 3+1);

WITH turn(id_turno) AS (
	VALUES(1)
	)
	,consulta AS (
		SELECT
		c.id_turno
		,tp.nombre_marcada
		,t.hora_salida
		,tp.tiempo_max
		,tp.tiempo_marcada
		,tp.numero_caida
		,t.vehiculo
		, SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)

		OVER(
			PARTITION BY tp.id_turno
			) AS total_caida
		FROM turn c
		INNER JOIN tiempo tp
			ON tp.id_turno = c.id_turno
		INNER JOIN turno t
			ON t.id_turno = tp.id_turno
		WHERE TRUE
			ORDER BY tp.id_tiempo
		)
	SELECT
	c.id_turno
	,c.vehiculo
	,c.nombre_marcada
	,c.hora_salida
	,c.tiempo_max
	,c.tiempo_marcada
	,c.numero_caida
	,total_caida
	,(total_caida * 5000) AS pago_total
	,c.vehiculo + 1 AS vehiculo_pago

	FROM consulta c;


