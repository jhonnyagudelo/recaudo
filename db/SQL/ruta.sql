CREATE OR REPLACE FUNCTION recaudo_marcadas( INT,  INT) RETURNS SETOF record
  AS
    $$

DECLARE
  data_marcada RECORD;
BEGIN

WITH turn(autobus, turno, fecha) AS (
  VALUES(7018, 1, '2019-05-10'::DATE )
  )
,data_marcada AS(
  SELECT
    t.id_turno
    ,t.numero_turno
    ,tp.nombre_marcada
    ,t.hora_salida
    ,tp.tiempo_max
    ,tp.tiempo_marcada
    ,tp.numero_caida
    ,t.vehiculo
    ,SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)
            OVER(
              PARTITION BY tp.id_turno
              ) AS total_caida

    ,CASE
        WHEN TRUE
          AND tp.numero_caida >=1
            THEN tp.numero_caida * 5000
      ELSE 0
    END AS cancelar

    FROM turn tn
      INNER JOIN turnos t
        ON tn.autobus = t.vehiculo
      LEFT JOIN tiempos tp
        ON tp.id_turno = t.id_turno
      WHERE TRUE
        AND tn.fecha::DATE = t.create_at::DATE
        AND tp.numero_turno = turno
        ORDER BY tp.tiempo_max, t.id_turno
  )
  SELECT
  d_m.id_turno
  ,d_m.numero_turno
  ,d_m.nombre_marcada
  ,d_m.hora_salida
  ,d_m.tiempo_max
  ,d_m.tiempo_marcada
  ,d_m.numero_caida
  ,d_m.total_caida
  ,d_m.cancelar
  ,d_m.vehiculo
  ,SUM(d_m.cancelar)OVER( PARTITION BY d_m.total_caida ) AS total_cancelar
FROM data_marcada d_m;
RETURN data_marcada;

END;
$$
LANGUAGE SQL
  IMMUTABLE;


CREATE OR REPLACE FUNCTION recaudo_marcadas(INT, INT, DATE) RETURNS SETOF RECORD
  AS
    $$
BEGIN
  RETURN QUERY
WITH turn(autobus, turno, fecha) AS (
  VALUES($1, $2, $3::DATE )
  )
,data_marcada AS(
  SELECT
    t.id_turno
    ,t.numero_turno
    ,tp.nombre_marcada
    ,t.hora_salida
    ,tp.tiempo_max
    ,tp.tiempo_marcada
    ,tp.numero_caida
    ,t.vehiculo
    ,SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)
            OVER(
              PARTITION BY tp.id_turno
              ) AS total_caida

    ,CASE
        WHEN TRUE
          AND tp.numero_caida >=1
            THEN tp.numero_caida * 5000
      ELSE 0
    END AS cancelar

    FROM turn tn
      INNER JOIN turnos t
        ON tn.autobus = t.vehiculo
      LEFT JOIN tiempos tp
        ON tp.id_turno = t.id_turno
      WHERE TRUE
        AND tn.fecha::DATE = t.create_at::DATE
        AND tp.numero_turno = turno
        ORDER BY tp.tiempo_max, t.id_turno
  )
  SELECT
  d_m.id_turno
  ,d_m.numero_turno
  ,d_m.nombre_marcada
  ,d_m.hora_salida
  ,d_m.tiempo_max
  ,d_m.tiempo_marcada
  ,d_m.numero_caida
  ,d_m.total_caida
  ,d_m.cancelar
  ,d_m.vehiculo
  ,SUM(d_m.cancelar)OVER( PARTITION BY d_m.total_caida ) AS total_cancelar
FROM data_marcada d_m;
END;
$$
LANGUAGE plpgsql
  VOLATILE;






CREATE OR REPLACE FUNCTION recaudo_marcadas(INT, INT, DATE) RETURNS SETOF
  TABLE(id_turno INT
    ,vehiculo INT
    ,numero_turno INT
    ,nombre_marcada varchar
    ,hora_salida TIME
    ,tiempo_max TIME
    ,tiempo_marcada TIME
    ,numero_caida INT
    ,total_caida bigint
    ,cancelar DOUBLE PRECISION
    ,total_cancelar DOUBLE PRECISION)
  AS
    $$
BEGIN

    RETURN QUERY
WITH turn(autobus, turno, fecha) AS (
  VALUES($1, $2, $3::DATE )
  )
,data_marcada AS(
  SELECT
    t.id_turno
    ,t.vehiculo
    ,t.numero_turno
    ,tp.nombre_marcada
    ,t.hora_salida
    ,tp.tiempo_max
    ,tp.tiempo_marcada
    ,tp.numero_caida
    ,SUM(CASE WHEN tp.numero_caida >=1 THEN tp.numero_caida ELSE 0 END)
            OVER(
              PARTITION BY tp.id_turno
              ) AS total_caida

    ,CASE
        WHEN TRUE
          AND tp.numero_caida >=1
            THEN tp.numero_caida * 5000
      ELSE 0
    END AS cancelar

    FROM turn tn
      INNER JOIN turnos t
        ON tn.autobus = t.vehiculo
      LEFT JOIN tiempos tp
        ON tp.id_turno = t.id_turno
      WHERE TRUE
        AND tn.fecha::DATE = t.create_at::DATE
        AND tp.numero_turno = tn.turno
        ORDER BY tp.tiempo_max, t.id_turno
  )
  SELECT
  d_m.id_turno
  ,d_m.vehiculo
  ,d_m.numero_turno
  ,d_m.nombre_marcada
  ,d_m.hora_salida
  ,d_m.tiempo_max
  ,d_m.tiempo_marcada
  ,d_m.numero_caida
  ,d_m.total_caida
  ,d_m.cancelar::DOUBLE PRECISION
  ,SUM(d_m.cancelar)OVER( PARTITION BY d_m.total_caida )::DOUBLE PRECISION AS total_cancelar
FROM data_marcada d_m;
END;
$$
LANGUAGE plpgsql
  VOLATILE;












WITH turn(autobus, turno, fecha) AS (
  VALUES(6043, 1, '2019-05-15'::DATE )
  )
,data_marcada AS(
  SELECT
    t.id_turno
    ,t.numero_turno
    ,tp.nombre_marcada
    ,t.hora_salida
    ,tp.tiempo_max
    ,tp.tiempo_marcada
    ,tp.numero_caida
    ,t.vehiculo
    ,SUM(CASE
          WHEN TRUE
             AND tp.numero_caida >= r_rj.min_caida
                THEN tp.numero_caida
        ELSE 0 END)  OVER(
              PARTITION BY tp.id_turno
              ) AS total_caida

    ,CASE
        WHEN TRUE
          AND tp.numero_caida >= r_rj.min_caida
            THEN
              (CASE
                WHEN TRUE
                  AND tp.numero_caida >= c_a.num_caida
                    THEN tp.numero_caida * c_a.valor_consecutivo
              ELSE 0 END)
        WHEN TRUE
          AND tp.numero_caida >= r_rj.min_caida
            THEN tp.numero_caida * r_rj.valor_caida
    END AS cancelar

    FROM turn tn
      INNER JOIN turnos t
        ON tn.autobus = t.vehiculo
        INNER JOIN rutas r
        ON t.id_ruta = r.id_ruta
      INNER JOIN ruta_relojes r_rj
        ON t.id_ruta = r_rj.id_ruta
      LEFT JOIN caidas_consecutivas c_a
        ON c_a.id_ruta_reloj = r_rj.id_ruta_reloj
      LEFT JOIN tiempos tp
        ON tp.id_turno = t.id_turno
      WHERE TRUE
        AND tn.fecha::DATE = t.create_at::DATE
        AND tp.numero_turno = tn.turno
        ORDER BY tp.tiempo_max, t.id_turno
  )
  SELECT
  d_m.id_turno
  ,d_m.numero_turno
  ,d_m.nombre_marcada
  ,d_m.hora_salida
  ,d_m.tiempo_max
  ,d_m.tiempo_marcada
  ,d_m.numero_caida
  ,d_m.total_caida
  ,d_m.cancelar
  ,d_m.vehiculo
  ,SUM(d_m.cancelar)OVER( PARTITION BY d_m.total_caida ) AS total_cancelar
FROM data_marcada d_m;





tp.numero_caida * r_rj.valor_caida







create or replace function ExpensiveDepartments()
  returns setof int as
declare
r holder%rowtype;
begin
for r in select departmentid,
  sum(salary) as totalsalary
    from GetEmployees()
group by departmentid loop

if (r.totalsalary > 70000)
  then
    r.totalsalary := CAST(r.totalsalary * 1.75 as int8);
  else
    r.totalsalary := CAST(r.totalsalary * 1.5 as int8);
end if;

if (r.totalsalary > 100000) then
return next r.departmentid;
end if;

end loop;
return;
end

language 'plpgsql';