
NEW.id_turno


INSERT INTO tiempo (
	id_turno
	, tiempo_max
)
SELECT
	NEW.id_turno
	, rr_r.tiempo_max + ()
FROM ruta r
	INNER JOIN ruta_reloj rr_r
		ON r.id_ruta = rr_r.id_ruta
WHERE TRUE
	AND r.id_ruta = NEW.id_ruta
;




ROLLBACK;
BEGIN;
INSERT INTO turno (
	id_ruta
	, numero_turno
)
VALUES (
	1
	, 1
)
RETURNING *
;
