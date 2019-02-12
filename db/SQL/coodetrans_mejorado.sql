CREATE OR REPLACE FUNCTION turn(num_vehiculo INT, ruta INT,num_turno INT,salida TIME, mensaje VARCHAR(50) DEFAULT 'Sin novedad') RETURNS VOID AS $$
DECLARE

/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar turno
 * statement in PostgreSQL.
 */

numturno INT;
nombre_ruta varchar(30);
BEGIN

INSERT INTO turno( vehiculo,id_ruta,numero_turno,hora_salida, mensaje) VALUES ( num_vehiculo, ruta, num_turno,salida, mensaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITO';
BEGIN

numturno:=(SELECT id_turno
        FROM turno t
          INNER JOIN rodamiento r_t
            ON r_t.numero_interno = t.vehiculo
          INNER JOIN vehiculo v_r
            ON r_t.numero_interno = v_r.numero_interno
        WHERE TRUE
          AND CURRENT_DATE::TIMESTAMP <= t.create_at
          AND t.vehiculo = num_vehiculo
          AND numero_turno = num_turno
        ORDER BY r_t.id_rodamiento DESC limit 1);

nombre_ruta:=(select nombre from ruta WHERE id_ruta = (SELECT id_ruta FROM turno WHERE id_turno= numturno));

UPDATE turno SET rodamiento = (
  SELECT
    r_t.id_rodamiento
  FROM turno t
  INNER JOIN rodamiento r_t
 	ON r_t.numero_interno = t.vehiculo
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= t.create_at
    AND t.create_at > r_t.create_at
    AND t.vehiculo = r_t.numero_interno
  ORDER BY  r_t.id_rodamiento DESC limit 1

) WHERE id_turno = numturno;

RAISE NOTICE 'El vehiculo de esta ruta es %', num_vehiculo;
RAISE NOTICE 'El numero de turno es %', num_turno;
RAISE NOTICE 'El en la ruta %', nombre_ruta;
END;
END;
$$ LANGUAGE plpgsql VOLATILE;


-----------------------------------------------------------------------------------------------------------

-- funcional
 ROLLBACK;
BEGIN;
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
    INNER JOIN ruta_reloj rr_r
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

-------------------------------------------------------------------------
-- numero de caida
CREATE OR REPLACE FUNCTION marked(idtiempo INT,time_marked TIME) RETURNS VOID AS $marcada$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar tiempos
 * statement in PostgreSQL.
 */

DECLARE
    tiempomax TIME;
    caida INT;
  BEGIN
  tiempomax:=(SELECT tiempo_max FROM tiempo WHERE id_tiempo = idtiempo);

  UPDATE tiempo SET tiempo_marcada = time_marked WHERE id_tiempo = idtiempo;
  RAISE NOTICE 'ingreso el tiempo  ------>%', time_marked;
  BEGIN
  UPDATE tiempo SET numero_caida =  (SELECT EXTRACT( MINUTE FROM tiempo_marcada - (tiempomax)))
                                      WHERE id_tiempo = idtiempo;
  -- RAISE NOTICE 'se cayo con   ------>% minutos', numero_caida;
  END;
  END;
  $marcada$ LANGUAGE plpgsql;
----------------------------------------------------------------------------------------------------
---con vehiculo
CREATE OR REPLACE FUNCTION add_turn_time() RETURNS TRIGGER AS $_time$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: trigger tiempo
 * statement in PostgreSQL.
 */

DECLARE
  horario_salida TIME;
  numturno INT;
  bus INT;
  BEGIN
  numturno:=(SELECT MAX(id_turno)FROM turno);
  bus:=(SELECT vehiculo FROM turno WHERE id_turno = numturno);
  horario_salida:=(SELECT hora_salida FROM turno WHERE id_turno = numturno);

    IF(TG_OP = 'UPDATE') THEN
    INSERT INTO tiempo (
      id_turno
      ,tiempo_max
      ,nombre_marcada
      ,num_vehiculo
    )
    SELECT
      NEW.id_turno
      ,CASE
       WHEN t.hora_salida < t_e.hora
             THEN t.hora_salida + (rr_r.tiempo_max || 'minute')::INTERVAL
       WHEN t.hora_salida >= t_e.hora
            THEN t.hora_salida + (t_e.tiempo_adicional || 'minute')::INTERVAL
       ELSE t.hora_salida + (rr_r.tiempo_max || 'minute')::INTERVAL
       END AS tiempo_max
       ,nombre_reloj
       ,vehiculo
    FROM turno t
      INNER JOIN ruta r
        ON t.id_ruta = r.id_ruta
      INNER JOIN ruta_reloj rr_r
        ON t.id_ruta = rr_r.id_ruta
      LEFT JOIN tiempo_extra t_e
        ON t_e.ruta_reloj_id = rr_r.id_ruta_reloj
      INNER JOIN reloj rl
        ON rr_r.id_reloj = rl.id_reloj
    WHERE TRUE
      AND t.id_turno = NEW.id_turno
      ORDER BY rr_r.id_ruta_reloj;
  END IF;
  RETURN NEW;
  END;
  $_time$ LANGUAGE plpgsql;

  CREATE TRIGGER after_insert_turn
  AFTER UPDATE ON turno
  FOR EACH ROW
  EXECUTE PROCEDURE add_turn_time();

------------------------------------------NUEVO CODIGO PARA COSTO RUTA-----------------------------------------------------
CREATE OR REPLACE FUNCTION  cost_turn (pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision,num_vehiculo INT)RETURNS void  AS $costo_turno$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Costo ruta
 * statement in PostgreSQL.
 */

  DECLARE
  /* num_positivo int; */
  costo DOUBLE PRECISION;
  porcentaje double precision;
  idcostoturno int;
  turno_id INT;
  idruta INT;
  idhelp INT;
  auxiliary_help DOUBLE PRECISION;
  formula DOUBLE PRECISION;
  BEGIN

--------------------------------------- JOIN VARIABLES-------------------------------


IF EXISTS(
  SELECT v_c.numero_interno
  FROM vehiculo v_c
    INNER JOIN rodamiento v_r
      ON v_c.numero_interno = v_r.numero_interno
    INNER JOIN turno t
      ON t.vehiculo = v_r.numero_interno
  WHERE TRUE
  AND v_c.numero_interno = num_vehiculo
  ORDER BY id_rodamiento DESC LIMIT 1
  ) THEN
  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, vehiculo)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, num_vehiculo);
  ELSE
    RAISE NOTICE 'EL VEHICULO NO EXISTE, INGRESELO AL SISTEMA ';
  END IF;


idcostoturno:=(
  SELECT
  c_t.id_costo_turno
  FROM costo_turno c_t
  INNER JOIN turno t
  ON  t.vehiculo = num_vehiculo
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= c_t.create_at
ORDER BY c_t.id_turno  DESC limit 1
);


----------------------UPDATE TURNO Y NUMERO TURNO
UPDATE costo_turno SET id_turno = (
  SELECT
    t.id_turno
  FROM turno t
    INNER JOIN costo_turno c_t
    ON c_t.vehiculo = t.vehiculo
  WHERE TRUE
    AND CURRENT_DATE::TIMESTAMP <= t.create_at
    AND t.vehiculo = num_vehiculo
  ORDER BY t.id_turno DESC limit 1) WHERE id_costo_turno = idcostoturno;

UPDATE costo_turno SET numero_turno  = (
   SELECT
  t.numero_turno
  FROM turno t
 INNER JOIN  costo_turno ct
  ON t.id_turno = ct.id_turno
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= ct.create_at
   AND t.vehiculo =  num_vehiculo
  ORDER BY t.id_turno, t.hora_salida DESC LIMIT 1 )
WHERE id_costo_turno = idcostoturno;



porcentaje:=(
  SELECT
    tt_t.valor_ruta
  FROM turno t
  INNER JOIN ruta r
    ON t.id_ruta = r.id_ruta
  INNER JOIN tarifa_positivo tt_t
    ON tt_t.tarifa_positivo_id = r.tarifa_positivo_id
  WHERE TRUE
    AND t.id_ruta = r.id_ruta
    AND t.vehiculo = num_vehiculo
    ORDER BY t.id_turno LIMIT 1 );
  RAISE NOTICE 'El porcentaje es %', porcentaje;

costo:=(SELECT
      tt_t.costo
      FROM turno t
      INNER JOIN ruta r
        ON t.id_ruta = r.id_ruta
      INNER JOIN tarifa_positivo tt_t
        ON tt_t.tarifa_positivo_id = r.tarifa_positivo_id
      WHERE TRUE
          AND t.id_ruta = r.id_ruta
          AND t.vehiculo = num_vehiculo
          ORDER BY t.id_turno LIMIT 1);
RAISE NOTICE 'El  costo por positivo es %', costo;

  idruta:=(
    SELECT
    r.id_ayuda
    FROM ruta r
    INNER JOIN turno t_r
      ON r.id_ruta = t_r.id_ruta
    INNER JOIN costo_turno t_c
      ON t_r.id_turno = t_c.id_turno
    WHERE TRUE
      AND t_r.vehiculo = num_vehiculo
    ORDER BY  t_r.id_turno, t_r.hora_salida DESC limit 1);

  idhelp:=(
    SELECT
      r_aa.id_ayuda
    FROM costo_turno t_ct
    INNER JOIN turno r_t
      ON r_t.id_turno = t_ct.id_turno
    INNER JOIN ruta r
      ON r.id_ruta = r_t.id_ruta
    INNER JOIN ayuda_auxiliar r_aa
      ON r.id_ayuda = r_aa.id_ayuda
    WHERE TRUE
    AND  t_ct.vehiculo = r_t.vehiculo
    ORDER BY t_ct.vehiculo DESC LIMIT 1 );

  auxiliary_help:= (
    SELECT
      r_aa.precio
    FROM costo_turno t_ct
    INNER JOIN turno r_t
      ON r_t.id_turno = t_ct.id_turno
    INNER JOIN ruta r
      ON r.id_ruta = r_t.id_ruta
    INNER JOIN ayuda_auxiliar r_aa
      ON r.id_ayuda = r_aa.id_ayuda
    WHERE TRUE
    AND  t_ct.vehiculo = r_t.vehiculo
    ORDER BY t_ct.vehiculo DESC LIMIT 1);

-----------------------------------------UPDATE ----------------------------------------------------------------------------
  --------------AYUDA AUXILIAR---------------------------
  IF (idruta = idhelp)
   THEN
    UPDATE costo_turno SET bea_neto = (bea_bruto - auxiliary_help) WHERE id_costo_turno = idcostoturno;
    RAISE NOTICE 'ayuda_auxiliar %', auxiliary_help;
  ELSE
  UPDATE costo_turno SET bea_neto =  bea_bruto   WHERE id_costo_turno = idcostoturno;
  END IF;

  -------------FORMULA PARA ABORDADOS O POSITIVOS-------------------------

    formula:=(positivo * porcentaje) * costo;
          RAISE NOTICE 'el resultado es %', formula;

    IF (positivo >=6) THEN
      UPDATE costo_turno SET costo_positivo = formula,
      bea_neto_total  = (bea_neto + formula)
      WHERE id_costo_turno= idcostoturno;
      ELSE
      UPDATE costo_turno SET bea_neto_total =  bea_neto WHERE id_costo_turno= idcostoturno;
    END IF;
    END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;


-------------------------------------------------------------------------------------------------------------------------


CREATE FUNCTION update_costo_turno() RETURNS TRIGGER AS $$
DECLARE
usuario varchar(20):=user;
fecha date:= CURRENT_DATE;
hora TIME:= CURRENT_TIME;
BEGIN
IF NEW.positivos <> OLD.positivos OR NEW.bea_bruto <> OLD.bea_bruto THEN
INSERT INTO auditoria_costo_ruta(id_costo_ruta, positivo_ante,positivo_nue, bea_bruto_ante, bea_bruto_nue, usuario,fecha,hora)
VALUES(OLD.id_costo_ruta, OLD.positivos, NEW.positivos, OLD.bea_bruto, NEW.bea_bruto, usuario, fecha, hora);
END IF;
RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;



CREATE TRIGGER update_costo AFTER UPDATE ON costo_turno
FOR EACH ROW
EXECUTE PROCEDURE update_costo_turno();


-------------------------------------------------------------------------------------------------------------------
