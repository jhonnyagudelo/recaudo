


CREATE TRIGGER ps_send_time
	AFTER INSERT
		ON turno
		FOR EACH ROW
			EXECUTE FUNCTION send_times();











 SELECT t_p.id_turno FROM ruta_reloj rr_r INNER JOIN ruta r ON rr_r.id_ruta = r.id_ruta INNER JOIN turno t ON t.id_ruta = r.id_ruta INNER JOIN tiempo t_p ON t_p.id_turno = t.id_turno WHERE t_p.id_turno= 9;

--uno de los 2


SELECT t_p.id_turno FROM ruta_reloj rr_r INNER JOIN ruta r ON rr_r.id_ruta = r.id_ruta INNER JOIN turno t ON t.id_ruta = r.id_ruta INNER JOIN tiempo t_p ON t_p.id_turno = t.id_tur
no WHERE t_p.id_tiempo= 1;














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
