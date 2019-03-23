CREATE OR REPLACE FUNCTION update_turns(passenger INT,auxiliary INT,positive INT,bloking INT,speed INT,bea DOUBLE PRECISION) RETURNS VOID AS $update_turn$
/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Costo ruta
 * statement in PostgreSQL.
 */
DECLARE
BEGIN
WITH updated_turns (pasajero, auxiliar, positivo, bloqueos, velocidad, bea_bruto)
AS
(
UPDATE turnos SET
    pasajero = passenger
    ,auxiliar =auxiliary
    ,positivo = positive
    ,bloqueo = bloking
    ,velocidad = speed
    ,bea_bruto = bea
    WHERE
    RETURNING id_turno, vehiculo
)
SELECT id_turno
FROM turnos
WHERE TRUE
IN (SELECT id_turno
      FROM updated_turns
        WHERE TRUE
      ORDER BY id_turno DESC LIMIT 1
 );
END;
$update_turn$ LANGUAGE plpgsql VOLATILE;










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

-- CREATE TYPE estado AS ENUM ('Pendiente','Transito','Terminado')

INSERT INTO turnos( vehiculo,id_ruta,numero_turno,hora_salida, mensaje) VALUES ( num_vehiculo, ruta, num_turno,salida, mensaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITO';


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
    AND CURRENT_DATE::TIMESTAMP <= r_t.create_at
    AND t.create_at > r_t.create_at
    AND t.vehiculo = r_t.numero_interno
  ORDER BY  r_t.id_rodamiento DESC limit 1

) WHERE id_turno = numturno;

RAISE NOTICE 'El vehiculo de esta ruta es %', num_vehiculo;
RAISE NOTICE 'El numero de turno es %', num_turno;
RAISE NOTICE 'El en la ruta %', nombre_ruta;

END;
$$ LANGUAGE plpgsql VOLATILE;


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
  tiempomax:=(SELECT tiempo_max FROM tiempos WHERE id_tiempo = idtiempo);

  UPDATE tiempos SET tiempo_marcada = time_marked WHERE id_tiempo = idtiempo;
  RAISE NOTICE 'ingreso el tiempo  ------>%', time_marked;

  UPDATE tiempos SET numero_caida =  (SELECT EXTRACT( MINUTE FROM tiempo_marcada - (tiempomax)))
                                      WHERE id_tiempo = idtiempo;
  -- RAISE NOTICE 'se cayo con   ------>% minutos', numero_caida;

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

  BEGIN

    IF(TG_OP = 'UPDATE') THEN
    INSERT INTO tiempos (
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
      INNER JOIN rutas r
        ON t.id_ruta = r.id_ruta
      INNER JOIN ruta_relojes rr_r
        ON t.id_ruta = rr_r.id_ruta
      LEFT JOIN tiempo_adicional t_e
        ON t_e.ruta_reloj_id = rr_r.id_ruta_reloj
      INNER JOIN relojes rl
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
  ----- INSERT
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

  --------------------------------------- JOIN VARIABLES-------------------------------
   INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, vehiculo)
    SELECT (pasajero, auxiliare, positivo, bloqueo, velocida, beabruto
         ,num_vehiculo
          FROM vehiculo v_r
            INNER JOIN rodamiento r_ct
              ON v_r.numero_interno = r_ct.numero_interno
            INNER JOIN turno r_t
              ON r_t.rodamiento = r_ct.id_rodamiento
            INNER JOIN ruta rr_t
              ON rr_t.id_ruta = r_t.id_ruta
          WHERE TRUE
          AND r_ct.numero_interno = num_vehiculo)) RETURNing *;


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
    /* AND CURRENT_DATE::TIMESTAMP <= t.create_at */
    AND t.vehiculo = num_vehiculo
  ORDER BY t.id_turno DESC limit 1)
WHERE id_costo_turno = idcostoturno;

 UPDATE costo_turno SET numero_turno  = (
   SELECT
  t.numero_turno
  FROM turno t
 INNER JOIN  costo_turno ct
  ON t.id_turno = ct.id_turno
  WHERE TRUE
  /* AND CURRENT_DATE::TIMESTAMP <= ct.create_at */
   AND t.vehiculo =  num_vehiculo
  ORDER BY  t.hora_salida DESC LIMIT 1 )
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
CREATE OR REPLACE FUNCTION turns(num_vehiculo INT, idruta INT,num_turno INT, salida TIME, mensaje VARCHAR(50) DEFAULT 'Sin novedad') RETURNS VOID AS $$
DECLARE

/*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar turno
 * statement in PostgreSQL.
 */

BEGIN
-- CREATE TYPE estado AS ENUM ('Pendiente','Transito','Terminado')
  ----- INSERT
IF EXISTS(
  SELECT v_r.id_rodamiento
  FROM rodamiento v_r
    INNER JOIN turno t
      ON t.id_rodamiento = v_r.numero_interno
  WHERE TRUE
  AND CURRENT_DATE::TIMESTAMP <= v_r.create_at
  ORDER BY id_rodamiento DESC LIMIT 1
  ) THEN
INSERT INTO
  turnos( vehiculo, id_ruta, numero_turno, rodamiento_id, hora_salida, mensaje)
    SELECT
      num_vehiculo
      ,idruta
      ,num_turno
      ,r_ct.id_rodamiento
      ,salida
      ,mensaje
    FROM vehiculos v_r
      INNER JOIN rodamientos r_ct
        ON v_r.numero_interno = r_ct.numero_interno
    WHERE TRUE
    AND v_r.numero_interno = num_vehiculo
    ORDER BY  r_ct.id_rodamiento DESC limit 1;
ELSE
    RAISE NOTICE 'Por favor crear otro rodamiento';
END IF;
END;
$$ LANGUAGE plpgsql VOLATILE;


-----------------------------------------------------------------------------------------------

# Creamos el Schema si no existe
CREATE SCHEMA IF NOT EXISTS db_test;

$$

-- Eliminamos el procedimiento almancenado si existise
DROP PROCEDURE IF EXISTS db_test.procedureTemp;

$$

CREATE PROCEDURE db_test.procedureTemp()
BEGIN
  DECLARE cuenta  INT DEFAULT 0;

  -- Si no existe la tabla de expedientes, la creamos.
  SELECT COUNT(*) INTO cuenta FROM `information_schema`.`tables` WHERE TABLE_SCHEMA='db_test' AND TABLE_NAME='expedientes' LIMIT 1;
  IF (cuenta = 0)  THEN
    CREATE TABLE `expedientes` (
      code             VARCHAR(15)  NOT NULL COMMENT 'Código del expediente',
      state            VARCHAR(20)  COMMENT 'Estado del expediente',
      stateChangedDate DATETIME     COMMENT 'Fecha/Hora en la que se produció el último cambio de estado',

      PRIMARY KEY `PK_Exp` (code)
    ) ENGINE=InnoDB CHARSET=utf8 collate=utf8_general_ci;
  END IF;

  -- Insertamos algunos expedientes de ejemplo
  DELETE FROM expedientes WHERE code IN ('exp1','exp2', 'exp3');
  INSERT INTO expedientes (code) VALUES ('exp1');
  INSERT INTO expedientes (code) VALUES ('exp2');
  INSERT INTO expedientes (code) VALUES ('exp3');



  -- Si no existe la tabla de cambios de esstado la creamos
  SELECT COUNT(*) INTO cuenta FROM `information_schema`.`tables` WHERE TABLE_SCHEMA='db_test' AND TABLE_NAME='expStatusHistory' LIMIT 1;
  IF (cuenta = 0)  THEN
    CREATE TABLE `expStatusHistory` (
      `id`    INT         AUTO_INCREMENT,
      `code`  VARCHAR(15) NOT NULL COMMENT 'Código del expediente',
      `state` VARCHAR(20) NOT NULL COMMENT 'Estado del expediente',
      `date`  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha/Hora en la que el expediente pasó a ese estado',
      PRIMARY KEY `PK_ExpHistory` (`id`)
    ) ENGINE=MyISAM CHARSET=utf8 collate=utf8_general_ci;  -- No transacciones => MyISAM
  END IF;
END;
$$

-- Invocamos el procedimiento almacenado
CALL db_test.procedureTemp();

$$
-- Borramos el procedimiento almacenado
DROP PROCEDURE IF EXISTS db_test.procedureTemp;

$$

-- Borramos el Trigger si existise
DROP TRIGGER IF EXISTS StatusChangeDateTrigger;

$$

-- Cremamos un Trigger sobre la tabla expedientes

CREATE TRIGGER StatusChangeDateTrigger
    BEFORE UPDATE ON expedientes FOR EACH ROW
    BEGIN
         -- ¿Ha cambiado el estado?
         IF NEW.state != OLD.state THEN
            -- Actualizamos el campo stateChangedDate a la fecha/hora actual
            SET NEW.stateChangedDate = NOW();

            -- A modo de auditoría, añadimos un registro en la tabla expStatusHistory
            INSERT INTO expStatusHistory (`code`, `state`) VALUES (NEW.code, NEW.state);
         END IF;
    END;
$$
DELIMITER;