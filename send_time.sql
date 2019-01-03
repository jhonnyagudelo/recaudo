CREATE OR REPLACE FUNCTION turn(idrodamiento INT, ruta INT,num_turno INT, mensaje VARCHAR(50)) RETURNS VOID AS $$
DECLARE

num_vehiculo INT;
numturno INT;
nombre_ruta varchar(30);
BEGIN

INSERT INTO turno( rodamiento, id_ruta, numero_turno, mensaje) VALUES ( idrodamiento, ruta, num_turno, mensaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITO';
END;
BEGIN
numturno:=(SELECT MAX(id_turno) FROM turno);
nombre_ruta:=(select nombre from ruta WHERE id_ruta = (SELECT id_ruta FROM turno WHERE id_turno= numturno));
num_vehiculo:=( SELECT numero_interno FROM rodamiento WHERE id_rodamiento = (SELECT rodamiento FROM turno WHERE id_turno =numturno ));
UPDATE turno SET vehiculo = num_vehiculo WHERE id_turno = numturno;
RAISE NOTICE 'El vehiculo de esta ruta es %', num_vehiculo;
RAISE NOTICE 'El numero de turno es %', num_turno;
RAISE NOTICE 'El en la ruta %', nombre_ruta;
END;






$$ LANGUAGE plpgsql VOLATILE;





SELECT hora_salida FROM rodamiento r JOIN turno t ON r.id_rodamiento = t.rodamiento WHERE t.id_turno = num_turno





WITH ruta (id_ruta) AS (

      VALUES (4)

    )

    , reloj AS (

      SELECT

        rr_r.*

      FROM ruta rr

        INNER JOIN ruta r_v

          ON r_v.id_ruta = rr.id_ruta

        INNER JOIN ruta_reloj rr_r

          ON rr_r.id_ruta = r_v.id_ruta

        INNER JOIN reloj rr_v

       ON rr_r.id_reloj = rr_v.id_reloj

      WHERE TRUE

    )

    SELECT



       ,horario_salida + ( rr.tiempo_max || 'minute')::INTERVAL

    FROM reloj rr;










CREATE OR REPLACE FUNCTION send_time(ruta int) RETURNS TABLE (turno INT,tiempo time) AS $$
DECLARE
horario_salida TIME;
num_turno INT;
BEGIN
num_turno:=(SELECT MAX(id_turno) FROM turno);
horario_salida:=( SELECT hora_salida FROM rodamiento r
                     JOIN turno t ON r.id_rodamiento = t.id_turno
                        WHERE t.id_turno = num_turno);

RAISE NOTICE 'HORARIO DE SALIDA %',horario_salida;
RAISE NOTICE 'NUMERO TURNO %',num_turno;

RETURN query
    WITH ruta (id_ruta) AS (
      VALUES (ruta)
    )
    , reloj AS (
      SELECT
        rr_r.*
      FROM ruta rr
        INNER JOIN ruta r_v
          ON r_v.id_ruta = rr.id_ruta
        INNER JOIN ruta_reloj rr_r
          ON rr_r.id_ruta = r_v.id_ruta
        INNER JOIN reloj rr_v
       ON rr_r.id_reloj = rr_v.id_reloj
      WHERE TRUE
    )
    SELECT
        num_turno
       ,horario_salida + ( rr.tiempo_max || 'minute')::INTERVAL
    FROM reloj rr;
    END;
$$ LANGUAGE plpgsql VOLATILE;
  COST 100
  ROW 1000;
ALTER FUNCTION send_times() OWNER TO postgres;











