
WITH RECURSIVE prueba AS (
SELECT
	id_turno
	,hora_salida
	,tiempo_max
	,id_ruta
	FROM turno
	WHERE id_turno = 1


	UNION

	SELECT
	t.id_turno
	,t.id_ruta
	FROM turno t
	INNER JOIN prueba p ON p.id_turno = t.id_turno

	UNION

	SELECT
	r.hora_salida
	p.id_turno
	FROM rodamiento r
	INNER JOIN  turno t_r
		ON r.id_rodamiento = t. rodamiento
	)
SELECT * FROM prueba p;





-------------------------
WITH RECURSIVE prueba AS (
SELECT
	,turno.rodamiento
	id_turno
	,id_ruta
	FROM turno
	WHERE id_turno = 1

	UNION

	SELECT
	,t.rodamiento
	t.id_turno
	,t.id_ruta
	FROM turno t
	INNER JOIN ruta rr ON rr.id_ruta = t.id_ruta
	UNION
	SELECT
	id_rodamiento
	,t_r.id_turno
	,id_turno
	FROM rodamiento r
	INNER JOIN  turno t_r
		ON r.id_rodamiento = t_r.rodamiento
	)
SELECT * FROM prueba p;





WITH  horario_salida, tiempo_maximo AS(
	SELECT tiempo_max
		FROM ruta_reloj rr_r
			INNER JOIN ruta r
				ON rr_r.id_ruta = r.id_ruta
			INNER JOIN	turno t
				ON t.id_ruta = r.id_ruta
					WHERE id_turno = 6
	),

horario_salida AS(
	SELECT hora_salida
		FROM rodamiento
		WHERE id_rodamiento = 11
	)
SELECT
 hora_salida + (tiempo_max || 'minute')::INTERVAL
FROM tiempo_maximo ,horario_salida;
