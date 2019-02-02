CREATE OR REPLACE FUNCTION costo_turno(pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision,idturno int, idtablavalor int, idayuda int)RETURNS void  as $$
DECLARE
resultado int;
num_positivo int;
costo int;
porcentaje double precision;
ayuda int;
ruta_ayuda varchar(20);
idcostoturno int;
num_vehiculo int;
BEGIN
INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, id_turno, id_tabla_valor, id_ayuda)
VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, idturno, idtablavalor, idayuda);

  RAISE NOTICE 'ingreso valores con exitos';


BEGIN

num_vehiculo:=( SELECT numero_interno FROM rodamiento WHERE id_rodamiento = (SELECT rodamiento FROM turno WHERE id_turno = (SELECT id_turno FROM costo_turno WHERE id_costo_turno = idcostoturno) ));
UPDATE costo_turno SET vehiculo = num_vehiculo WHERE id_costo_turno = idcostoturno;
RAISE NOTICE 'El vehiculo es %', num_vehiculo;
--consulta ayuda
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
END;
  $$ LANGUAGE plpgsql VOLATILE;

-----------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION turn(idrodamiento INT, ruta INT,num_turno INT, mensaje VARCHAR(50) DEFAULT 'Sin novedad') RETURNS VOID AS $$
DECLARE

num_vehiculo INT;
numturno INT;
nombre_ruta varchar(30);
horario_salida TIME;
BEGIN

INSERT INTO turno( rodamiento, id_ruta, numero_turno, mensaje) VALUES ( idrodamiento, ruta, num_turno, mensaje);
RAISE NOTICE 'INGRESARON LOS DATOS CON EXITO';
BEGIN
numturno:=(SELECT MAX(id_turno) FROM turno);
nombre_ruta:=(select nombre from ruta WHERE id_ruta = (SELECT id_ruta FROM turno WHERE id_turno= numturno));
num_vehiculo:=( SELECT numero_interno FROM rodamiento WHERE id_rodamiento = (SELECT rodamiento FROM turno WHERE id_turno =numturno ));
UPDATE turno SET vehiculo = num_vehiculo
  ,hora_salida = (SELECT hora_salida FROM rodamiento WHERE id_rodamiento = (SELECT rodamiento FROM turno WHERE id_turno = numturno) ) WHERE id_turno = numturno;
RAISE NOTICE 'El vehiculo de esta ruta es %', num_vehiculo;
RAISE NOTICE 'El numero de tur"no es %', num_turno;
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
-------------------------------------------------------------------------------------
-----sirve
CREATE OR REPLACE FUNCTION add_turn_time() RETURNS TRIGGER AS $_time$
DECLARE
  horario_salida TIME;
  numturno INT;
  BEGIN
  numturno:=(SELECT MAX(id_turno)FROM turno);
  horario_salida:=(SELECT hora_salida FROM turno WHERE id_turno = numturno);

    IF(TG_OP = 'UPDATE') THEN
    INSERT INTO tiempo (
      id_turno
      ,tiempo_max
    )
    SELECT
      NEW.id_turno
       ,horario_salida + (rr_r.tiempo_max || 'minute')::INTERVAL
    FROM ruta r
      INNER JOIN ruta_reloj rr_r
        ON r.id_ruta = rr_r.id_ruta
    WHERE TRUE
      AND r.id_ruta = NEW.id_ruta
    ;
  END IF;
  RETURN NEW;

  END;

    $_time$ LANGUAGE plpgsql;

  CREATE TRIGGER after_insert_turn
  AFTER UPDATE ON turno
  FOR EACH ROW
  EXECUTE PROCEDURE add_turn_time();


----------------------------------------------------------------------------------------------------------------
---con vehiculo
CREATE OR REPLACE FUNCTION add_turn_time() RETURNS TRIGGER AS $_time$
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
       ,horario_salida + (rr_r.tiempo_max || 'minute')::INTERVAL
       ,nombre_reloj
       ,vehiculo
    FROM turno t
      INNER JOIN ruta r
        ON t.id_ruta = r.id_ruta
      INNER JOIN ruta_reloj rr_r
        ON r.id_ruta = rr_r.id_ruta
       INNER JOIN reloj rl
        ON rr_r.id_reloj = rl.id_reloj
    WHERE TRUE
      AND t.id_turno = NEW.id_turno
      ORDER BY rr_r.id_ruta_reloj
    ;
  END IF;
  RETURN NEW;

  END;

    $_time$ LANGUAGE plpgsql;

------------------------------------------NUEVO CODIGO PARA COSTO RUTA-----------------------------------------------------
CREATE OR REPLACE FUNCTION  spending_shift(pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision,idturno int)RETURNS void  AS $costo_turno$
  DECLARE
  num_positivo int;
  costo DOUBLE PRECISION;
  porcentaje double precision;
  ruta_ayuda varchar(20);
  idcostoturno int;
  num_vehiculo int;
  turno INT;
  idhelp INT;
  turn_help DOUBLE PRECISION;
  formula DOUBLE PRECISION;
  BEGIN
  ----- INSERT

  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto, id_turno)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto, idturno);
    RAISE NOTICE 'ingreso valores con exitos';
  BEGIN
    idcostoturno:=(SELECT MAX(id_costo_turno)FROM costo_turno);

    num_vehiculo:=( SELECT numero_interno FROM rodamiento
                      WHERE id_rodamiento =
                        (SELECT rodamiento FROM turno
                            WHERE id_turno =
                              (SELECT id_turno FROM costo_turno
                                  WHERE id_costo_turno = idcostoturno)));
    idhelp:=(SELECT aa.id_ayuda FROM costo_turno ct
                    INNER JOIN turno t
                      ON ct.id_turno = t.id_turno
                    INNER JOIN ruta r
                      ON r.id_ruta = t.id_ruta
                    INNER JOIN ayuda_auxiliar aa
                      ON aa.id_ayuda = r.id_ayuda WHERE  ct.id_costo_turno =idcostoturno);

    turn_help:= (SELECT aa.precio FROM costo_turno ct
                    INNER JOIN turno t
                      ON ct.id_turno = t.id_turno
                    INNER JOIN ruta r
                      ON r.id_ruta = t.id_ruta
                    INNER JOIN ayuda_auxiliar aa
                      ON aa.id_ayuda = r.id_ayuda WHERE  ct.id_costo_turno = idcostoturno);
    --------INSERT VEHICULO--------------

    UPDATE costo_turno SET vehiculo = (SELECT numero_interno FROM rodamiento
                                        WHERE id_rodamiento =
                                          (SELECT rodamiento FROM turno
                                              WHERE id_turno =
                                                (SELECT id_turno FROM costo_turno
                                                    WHERE id_costo_turno = idcostoturno))),
                          numero_turno = (SELECT numero_turno FROM turno
                                            WHERE id_turno =
                                              (SELECT id_turno FROM costo_turno
                                                WHERE id_costo_turno = idcostoturno)) where id_costo_turno = idcostoturno;

      RAISE NOTICE 'El vehiculo es %', num_vehiculo;
      -- RAISE NOTICE 'El numero del turno es %', numero_turno;

    -------------AYUDA AUXILIAR---------------------------

    IF(idturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
            RAISE NOTICE 'ayuda_auxiliar %', turn_help;
      ELSEIF(idturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
          RAISE NOTICE 'ayuda_auxiliar %', turn_help;
      ELSE
          UPDATE costo_turno SET bea_neto = bea_bruto;
      END IF;
  -------------FORMULA PARA ABORDADOS O POSITIVOS-------------------------
    porcentaje:=(SELECT tv.valor_ruta FROM costo_turno cr
                  INNER JOIN turno t
                    ON cr.id_turno = t.id_turno
                  INNER JOIN ruta r
                    ON r.id_ruta = t.id_ruta
                  INNER JOIN tabla_valor tv
                    ON tv.id_valor = r.id_tabla_valor WHERE cr.id_costo_turno  = idcostoturno);
      RAISE NOTICE 'El porcentaje es %', porcentaje;

    costo:=(SELECT tv.costo FROM costo_turno cr
                INNER JOIN turno t
                  ON cr.id_turno = t.id_turno
                INNER JOIN ruta r
                  ON r.id_ruta = t.id_ruta
                INNER JOIN tabla_valor tv
                  ON tv.id_valor = r.id_tabla_valor WHERE cr.id_costo_turno  = idcostoturno);
      RAISE NOTICE 'El  costo por positivo es %', costo;

    num_positivo:=(SELECT positivos FROM costo_turno WHERE id_costo_turno = idcostoturno);
          RAISE NOTICE 'nuemro positivo es %', num_positivo;

    formula:=(num_positivo * porcentaje) * costo;
          RAISE NOTICE 'el resultado es %', formula;


    IF (num_positivo >=6) THEN
      UPDATE costo_turno SET costo_positivo = formula,
      bea_neto_total  = (bea_neto + formula)
      WHERE id_costo_turno= idcostoturno;
      ELSIF (num_positivo <= 5) THEN
      UPDATE costo_turno SET bea_neto_total =  bea_neto;
    END IF;
  END;
  END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------------------------------------------------


CREATE FUNCTION update_costo_ruta() RETURNS TRIGGER AS $$
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
END
$$ LANGUAGE PLPGSQL



CREATE TRIGGER update_costo AFTER UPDATE ON costo_ruta
FOR EACH ROW
EXECUTE PROCEDURE update_costo_ruta();


-------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION shift_cost() RETURNS TRIGGER AS $costo_de_turno$
  DECLARE
  BEGIN

  IF(TG_OP = 'UPDATE') THEN
    INSERT INTO costo_turno(
      id_turno
      ,vehiculo
      ,numero_turno
    )
    SELECT
      NEW.id_turno
      ,vehiculo
      ,numero_turno
    FROM turno
    WHERE id_turno = NEW.id_turno
    ORDER BY id_turno;
  END IF;
  RETURN NEW;
  END;
$costo_de_turno$ LANGUAGE plpgsql;


  CREATE TRIGGER after_insert_costo
  AFTER UPDATE ON turno
  FOR EACH ROW
  EXECUTE PROCEDURE shift_cost();
  ------------------------------------------------------------------------------------------------------------------------
  WITH turn(id_turno) AS (
  VALUES(1)
  )
, data_turno AS (
  SELECT
    t.*
    , coalesce((
            SELECT
              EXTRACT(MINUTES FROM t.hora_salida - t_1.hora_salida)
            FROM turno t_1
            WHERE TRUE
              AND CURRENT_DATE::TIMESTAMP <= t_1.create_at
              AND t_1.hora_salida < t.hora_salida
              AND t_1.id_ruta = t.id_ruta
            limit 1
          ),7) AS diferencia
  FROM turn tn
    INNER JOIN turno t
      ON t.id_turno = tn.id_turno
    WHERE TRUE
)

-- ,vehiculo_next AS(
--  SELECT
--      t.vehiculo
--    FROM turno t
--      INNER JOIN rodamiento r_t
--        ON r_t.id_rodamiento = t.rodamiento
--      INNER JOIN vehiculo v_r
--        ON r_t.numero_interno = v_r.numero_interno
--    WHERE TRUE
--    AND r_t.vehiculo >t.numero_interno
--   ORDER BY r_t.id_rodamiento, r_t.numero_interno asc limit 1
--  )


,consulta AS (
    SELECT
    t.id_turno
    ,t.numero_turno
    ,tp.nombre_marcada
    ,t.hora_salida
    ,tp.tiempo_max
    ,tp.tiempo_marcada
    ,tp.numero_caida
    ,t.vehiculo
    ,r.nombre
    ,diferencia

    ,SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)
            OVER(
              PARTITION BY tp.id_turno
              ) AS total_caida

  ,CASE
    WHEN tp.numero_caida >= diferencia
      THEN diferencia
        ELSE tp.numero_caida
  END AS min_cancelar

    ,CASE
        WHEN tp.nombre_marcada = 'Albeiro'
            THEN (CASE
        WHEN tp.numero_caida >= diferencia
            THEN diferencia
        ELSE tp.numero_caida
              END) * 10000

        WHEN tp.nombre_marcada = 'La Y'
            THEN (CASE
        WHEN tp.numero_caida >= diferencia
            THEN diferencia
        ELSE tp.numero_caida
              END) * 10000

        WHEN tp.numero_caida >=1
          THEN (CASE
        WHEN tp.numero_caida >= diferencia
            THEN diferencia
        ELSE tp.numero_caida
            END) * 5000
        ELSE 0
    END AS cancelar



    FROM data_turno t
    INNER JOIN tiempo tp
      ON tp.id_turno = t.id_turno
    INNER JOIN turn tn
       ON tp.id_turno = tn.id_turno
    INNER JOIN ruta r
      ON t.id_ruta = r.id_ruta

    WHERE TRUE
    ORDER BY tp.tiempo_max
    )

    SELECT
    c.id_turno
    -- ,c.nombre
    ,c.vehiculo
    ,c.numero_turno
    ,c.nombre_marcada
    ,c.hora_salida
    ,c.tiempo_max
    ,c.tiempo_marcada
    ,c.numero_caida
    ,c.total_caida
    ,cancelar
    -- ,min_cancelar
    ,SUM(cancelar)OVER( PARTITION BY total_caida ) AS total_cancelar
    ,vehiculo
FROM consulta c;
---------------------------------------------------------------------------------------------------------------------------






CREATE OR REPLACE FUNCTION  spending_shift(pasajero int, auxiliare int,positivo int,bloqueo int,velocida int, beabruto DOUBLE precision)RETURNS void  AS $costo_turno$
  /*
 * Author: Jhonny Stiven Agudelo Tenorio
 * Purpose: Insertar turno
 * statement in PostgreSQL.
 */

  DECLARE
  num_positivo int;
  costo DOUBLE PRECISION;
  porcentaje double precision;
  ruta_ayuda varchar(20);
  idcostoturno int;
  num_vehiculo int;
  turno INT;
  idhelp INT;
  turn_help DOUBLE PRECISION;
  formula DOUBLE PRECISION;
  BEGIN
  ----- INSERT

  INSERT INTO costo_turno( pasajeros, auxiliares, positivos, bloqueos, velocidad, bea_bruto,vehiculo)
    VALUES(pasajero, auxiliare, positivo, bloqueo, velocida, beabruto,vehiculo);
    RAISE NOTICE 'ingreso valores con exitos';
  BEGIN
    idcostoturno:=(SELECT id_turno
										FROM turno t
											INNER JOIN rodamiento r_t
												ON r_t.id_rodamiento = t.rodamiento
											INNER JOIN vehiculo v_r
												ON r_t.numero_interno = v_r.numero_interno
										WHERE TRUE
											AND CURRENT_DATE::TIMESTAMP <= t.create_at
											AND t.vehiculo = 7118
												ORDER BY r_t.id_rodamiento, r_t.hora_salida DESC limit 1);


    idhelp:=(SELECT aa.id_ayuda FROM costo_turno ct
                    INNER JOIN turno t
                      ON ct.id_turno = t.id_turno
                    INNER JOIN ruta r
                      ON r.id_ruta = t.id_ruta
                    INNER JOIN ayuda_auxiliar aa
                      ON aa.id_ayuda = r.id_ayuda WHERE  ct.id_costo_turno =idcostoturno);

    turn_help:= (SELECT aa.precio FROM costo_turno ct
                    INNER JOIN turno t
                      ON ct.id_turno = t.id_turno
                    INNER JOIN ruta r
                      ON r.id_ruta = t.id_ruta
                    INNER JOIN ayuda_auxiliar aa
                      ON aa.id_ayuda = r.id_ayuda WHERE  ct.id_costo_turno = idcostoturno);
    --------INSERT VEHICULO--------------

    UPDATE costo_turno SET numero_turno = (SELECT numero_turno FROM turno
                                            WHERE id_turno =
                                          (SELECT id_turno FROM costo_turno
                                            WHERE id_costo_turno = idcostoturno))
    																				WHERE id_costo_turno = idcostoturno;


    -------------AYUDA AUXILIAR---------------------------

    IF(idturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
            RAISE NOTICE 'ayuda_auxiliar %', turn_help;
      ELSEIF(idturno = idhelp) THEN
      UPDATE costo_turno SET bea_neto = (bea_bruto - turn_help) WHERE id_costo_turno = idcostoturno;
          RAISE NOTICE 'ayuda_auxiliar %', turn_help;
      ELSE
          UPDATE costo_turno SET bea_neto = bea_bruto;
      END IF;
  -------------FORMULA PARA ABORDADOS O POSITIVOS-------------------------
    porcentaje:=(SELECT
    tt_t.valor_ruta
      FROM costo_turno cr
      INNER JOIN turno t
        ON cr.vehiculo = t.vehiculo
      INNER JOIN ruta r
        ON r.id_ruta = t.id_ruta
      INNER JOIN tarifa_positivo tt_t
        ON tt_t.tarifa_positivo_id = r.tarifa_positivo_id
        WHERE TRUE
    		AND cr.vehiculo = t.vehiculo
    		AND cr.numero_turno=t.numero_turno
    AND cr.id_costo_turno  = idcostoturno );
      RAISE NOTICE 'El porcentaje es %', porcentaje;

    costo:=(SELECT tv.costo FROM costo_turno cr
                INNER JOIN turno t
                  ON cr.id_turno = t.id_turno
                INNER JOIN ruta r
                  ON r.id_ruta = t.id_ruta
                INNER JOIN tabla_valor tv
                  ON tv.id_valor = r.id_tabla_valor WHERE cr.id_costo_turno  = idcostoturno);
      RAISE NOTICE 'El  costo por positivo es %', costo;

    num_positivo:=(SELECT positivos FROM costo_turno WHERE id_costo_turno = idcostoturno);
          RAISE NOTICE 'nuemro positivo es %', num_positivo;

    formula:=(num_positivo * porcentaje) * costo;
          RAISE NOTICE 'el resultado es %', formula;


    IF (num_positivo >=6) THEN
      UPDATE costo_turno SET costo_positivo = formula,
      bea_neto_total  = (bea_neto + formula)
      WHERE id_costo_turno= idcostoturno;
      ELSIF (num_positivo <= 5) THEN
      UPDATE costo_turno SET bea_neto_total =  bea_neto;
    END IF;
  END;
  END;
  $costo_turno$ LANGUAGE plpgsql VOLATILE;
