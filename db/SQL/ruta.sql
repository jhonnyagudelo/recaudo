CREATE OR REPLACE FUNCTION recaudo_marcadas( INT,  INT) RETURNS SETOF record
  AS
    $$

DECLARE
  data_marcada RECORD;
BEGIN

WITH turn(autobus, turno, fecha) AS (
  VALUES(7018, 1, '2019-06-08'::DATE )
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
        ON tn.turno = t.id_turno
        AND tn.autobus = t.vehiculo
        AND tn.fecha::DATE = t.create_at::DATE
      LEFT JOIN tiempos tp
        ON tp.id_turno = t.id_turno
      WHERE TRUE
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
  ,SUM(d_m.cancelar)OVER( PARTITION BY d_m.total_caida ) AS total_cancelar
FROM data_marcada d_m;

RETURN data_marcada;

END;
$$
LANGUAGE SQL
  IMMUTABLE;





  ,CASE WHEN total_cancelar >= tp.recaudo_max
  THEN tp.recaudo_max
   ELSE total_cancelar
   END AS pagar











  ,CASE WHEN total_cancelar >= tp.recaudo_max
  THEN tp.recaudo_max
   ELSE total_cancelar
   END AS pagar







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