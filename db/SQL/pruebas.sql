ROLLBACK;

BEGIN;


CREATE OR REPLACE FUNCTION send_time() RETURN VOID AS $$
DECLARE
hora_salida TIME;
num_ruta INT;
BEGIN
hora_salida: SELECT hora_salida FROM rodamiento WHERE id_rodamiento = (SELECT id_turno FROM turno WHERE id_turno=);
    WITH valor (id_ruta, hora_salida) AS (
      VALUES (1, '06:00:00'::TIME)
    )
    , reloj AS (
      SELECT
        rr_r.*
        , v.hora_salida
      FROM valor v
        INNER JOIN ruta r_v
          ON r_v.id_ruta = v.id_ruta
        INNER JOIN ruta_reloj rr_r
          ON rr_r.id_ruta = r_v.id_ruta
        INNER JOIN reloj rr_v
       ON rr_r.id_reloj = rr_v.id_reloj
      WHERE TRUE
    )
    SELECT
      ,v.hora_salida + ( v.tiempo_max || 'minute')::INTERVAL
    FROM reloj v;



-- busqeuda por ruta
WITH marcada(ruta) AS (
			VALUES (1)),
	turno AS
	( SELECT rr_t.id_ruta
										,m.ruta
										,t.id_turno
				FROM marcada m
				INNER JOIN ruta_reloj rr_t ON rr_t.id_ruta = m.ruta
				INNER JOIN ruta r ON r.id_ruta = rr_t.id_ruta
				INNER JOIN turno t ON t.id_turno = r.id_ruta
				WHERE TRUE)
				SELECT  m.ruta

				FROM turno m;


-- busqueda de ruta por id_turno
WITH num_turno(turno) AS (
	VALUES (2)),
turno AS
(SELECT t.*
	,t_r.turno
	,r_t.nombre
	FROM num_turno t_r
	INNER JOIN turno t ON t.id_turno = t_r.turno
	INNER JOIN ruta r_t ON r_t.id_ruta = t.id_ruta
	INNER JOIN ruta_reloj rr_r ON r_t.id_ruta = rr_r.id_ruta
	WHERE TRUE)
SELECT
	t_r.turno
	,t_r.nombre
	INTO TEMP  TABLE turnitoo
FROM turno t_r;


-- insertar consulta de turno
 INSERT INTO tiempo (id_turno) SELECT turno FROM turnitoo


WITH RECURSIVE turno_tiempo(turno,ruta,hora_salida) AS (
    SELECT  t_t.turno, t_t.ruta,t_t.hora_salida
    FROM prueba t_t
    UNION


    SELECT r.hora_salida
      ,t.id_turno
      ,rr_r.ruta
        FROM rodamiento


    )

WITH RECURSIVE employee_recursive(distance, employee_name, manager_name) AS (
    SELECT 1, employee_name, manager_name
    FROM employee
    WHERE manager_name = 'Mary'
  UNION ALL
    SELECT er.distance + 1, e.employee_name, e.manager_name
    FROM employee_recursive er, employee e
    WHERE er.employee_name = e.manager_name+

  )
SELECT distance, employee_name FROM employee_recursive;