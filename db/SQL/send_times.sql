
NEW.id_turno


INSERT INTO gasto_turno (
	id_turno
	,conduce
	,pago_conductor
	,num_turno
	,vehiculo
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

INSERT INTO






ROLLBACK;
BEGIN;
INSERT INTO gasto_turno (
	id_turno
	, num_turno
)
VALUES (
	1
	, 1
)
RETURNING *
;
