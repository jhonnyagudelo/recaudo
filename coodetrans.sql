CREATE OR REPLACE FUNCTION costo_turno(pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto int,idturno int, idtablavalor int, idayuda int)RETURNS void  as $$
DECLARE
resultado int;
num_positivo int;
costo int;
porcentaje numeric;
ayuda int;
ruta_ayuda varchar(20);
idcostoturno int;
num_vehiculo int;
BEGIN
INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, id_turno, id_tabla_valor, id_ayuda)
VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, idturno, idtablavalor, idayuda);

  RAISE NOTICE 'ingreso valores con exitos';
idcostoturno:=(SELECT MAX(id_costo_turno)FROM costo_turno);
num_vehiculo:=( SELECT vehiculo FROM turno WHERE id_turno = (SELECT id_costo_turno FROM costo_turno WHERE id_turno =idcostoturno));

UPDATE costo_turno SET vehiculo = num_vehiculo WHERE id_costo_turno = idcostoturno;

ayuda:= ( SELECT precio FROM costo_turno AS a1 INNER JOIN ayuda_auxiliar b1 ON a1.id_ayuda = b1.id_ayuda WHERE id_costo_turno = idcostoturno );
ruta_ayuda :=(SELECT nombre_ruta FROM costo_turno AS a1 INNER JOIN ayuda_auxiliar b1 ON a1.id_ayuda = b1.id_ayuda WHERE id_costo_turno = idcostoturno);

IF(idayuda = 1) THEN
  UPDATE costo_turno SET bea_neto=(bea_bruto - ayuda);
  RAISE NOTICE 'ingreso por %', ruta_ayuda;
    ELSIF (idayuda = 2) THEN
      UPDATE costo_turno SET bea_neto=(bea_bruto - ayuda);
      RAISE NOTICE 'ingreso por %', ruta_ayuda;
      ELSE
        UPDATE costo_turno SET bea_neto = bea_bruto;
END IF;

    porcentaje:=(select valor_ruta FROM costo_turno AS a1 INNER JOIN tabla_valor b1 ON a1.id_tabla_valor = id_valor WHERE id_costo_turno =idcostoturno );
    costo:=(SELECT b1.costo FROM costo_turno AS a1 INNER JOIN tabla_valor b1 ON a1.id_tabla_valor = b1.id_Valor WHERE id_costo_turno = idcostoturno);
    num_positivo:=(SELECT positivos FROM costo_turno WHERE id_costo_turno = idcostoturno);
    resultado:=(num_positivo * porcentaje) * costo;
    RAISE NOTICE 'el resultado es %', resultado;

  IF (num_positivo >=6) THEN

    UPDATE costo_turno SET costo_positivo = resultado,
    bea_neto_total  = (bea_neto + resultado)
    WHERE id_costo_turno= idcostoturno;
    ELSIF (num_positivo <= 5) THEN
    UPDATE costo_turno SET bea_neto_total =  bea_neto;
  END IF;

END;
  $$ LANGUAGE plpgsql VOLATILE;

-----------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION turn(idrodamiento INT, ruta INT,num_turno INT, mensaje VARCHAR(50)) RETURNS VOID AS $$
DECLARE

num_vehiculo INT;
numturno INT;
nombre_ruta varchar(30);
BEGIN

INSERT INTO turno( rodamiento, id_ruta, numero_turno, mensaje) VALUES ( idrodamiento, ruta, num_turno, mensaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITO';

BEGIN
numturno:=(SELECT MAX(id_turno) FROM turno);
nombre_ruta:=(select nombre from ruta WHERE id_ruta = (SELECT id_ruta FROM turno WHERE id_turno= numturno));
num_vehiculo:=( SELECT numero_interno FROM rodamiento WHERE id_rodamiento = (SELECT rodamiento FROM turno WHERE id_turno =numturno ));
UPDATE turno SET vehiculo = num_vehiculo WHERE id_turno = numturno;
RAISE NOTICE 'El vehiculo de esta ruta es %', num_vehiculo;
RAISE NOTICE 'El numero de turno es %', num_turno;
RAISE NOTICE 'El en la ruta %', nombre_ruta;
END;
END;
$$ LANGUAGE plpgsql VOLATILE;




------------hacer cosas en una sola consulta,
 ROLLBACK;
BEGIN;


WITH valor (id_ruta, hora_salida) AS (
  VALUES (5, '15:10:00'::TIME)
)
, reloj AS (
  SELECT
    rr_r.*
    , v.hora_salida
    -- , v.hora_salida::TIME + (SELECT (EXTRACT (MINUTE FROM rr_r.tiempo_max)) || ' minutes')::INTERVAL
    , SUM(rr_r.tiempo_max)
      OVER (
        PARTITION BY rr_r.id_reloj
        ORDER BY rr_r.id_ruta_reloj) AS tiempo_acumulado
  FROM valor v
    INNER JOIN ruta r_v
      ON r_v.id_ruta = v.id_ruta
    INNER JOIN ruta_reloj rr_r
      ON rr_r.id_ruta = r_v.id_ruta
  WHERE TRUE
  ORDER BY id_ruta
)
SELECT

  v.hora_salida + v.tiempo_acumulado
FROM reloj v;

-----------------------------------------------------------------------------------------------------------

-- funcional
WITH valor (id_turno, hora_salida) AS (
  VALUES (9, '09:57:00'::TIME)
)
, reloj AS (
  SELECT
    rr_r.*
    , rr_v.nombre_reloj
    , v.hora_salida
  FROM valor v
    INNER JOIN tiempo tp
      ON tp.id_turno = v.id_turno
    INNER JOIN turno tr
      ON tp.id_turno = tr.id_turno
    INNER JOIN ruta r
      ON tr.id_ruta = r.id_ruta
    INNER JOIN ruta_reloj rr_r\e
      ON rr_r.id_ruta = r.id_ruta
    INNER JOIN reloj rr_v
   ON rr_r.id_reloj = rr_v.id_reloj
  WHERE TRUE
  ORDER BY id_ruta
)
SELECT
  v.nombre_reloj
  ,v.hora_salida + ( v.tiempo_max || 'minute')::INTERVAL
FROM reloj v;
-----------------------------------------------------------------------------------------------------------------------

  CREATE TRIGGER after_insert_turn
  AFTER INSERT ON turno
  FOR EACH ROW
  EXECUTE PROCEDURE insert_turn();


  ---TURNO A TIEMPO TRIIGER
  SELECT t.id_ruta FROM ruta_reloj rr_r
    INNER JOIN ruta r
      ON rr_r.id_ruta = r.id_ruta
    INNER JOIN turno t
      ON t.id_ruta = r.id_ruta
    WHERE
      t.id_turno = 1;

--------------------------------------------------------------------------------------------------------------------

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
FROM turno t_r;


------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION send_time(turno int) RETURNS SETOF tiempo AS $$
DECLARE
hora_salida TIME;
BEGIN
hora_salida:= (SELECT r.hora_salida
                  FROM rodamiento r
                    INNER JOIN turno t
                        ON t.rodamiento = r.id_rodamiento WHERE id_turno = 1);


    WITH valor (id_ruta, hora_salida) AS (
      VALUES (1, '06:00:00'::TIME)
    )
    , reloj AS (
      SELECT
        rr_r.*
        , rr_v.nombre_reloj
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
      v.nombre_reloj
      ,v.hora_salida + ( v.tiempo_max || 'minute')::INTERVAL
    FROM reloj v;