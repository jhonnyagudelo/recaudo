CREATE OR REPLACE FUNCTION "public"."storeopeninghours_tostring" () RETURNS setof storeopeninghours_tostring_rs AS
$BODY$
DECLARE
  returnrec storeopeninghours_tostring_rs;
BEGIN
    BEGIN
        CREATE TEMPORARY TABLE tmpopeninghours (
            colone text,
            coltwo text,
            colthree text
        );
    EXCEPTION WHEN OTHERS THEN
        TRUNCATE TABLE tmpopeninghours; -- TRUNCATE if the table already exists within the session.
    END;
    insert into tmpopeninghours VALUES ('1', '2', '3');
    insert into tmpopeninghours VALUES ('3', '4', '5');
    insert into tmpopeninghours VALUES ('3', '4', '5');

    FOR returnrec IN SELECT * FROM tmpopeninghours LOOP
        RETURN NEXT returnrec;
    END LOOP;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE;


select * from storeopeninghours_tostring()





------------------------------------------------
-- devolver con un query



CREATE OR REPLACE FUNCTION sp_consulta_topes(IN text character varying,idObraSocial integer, idPlan Integer)
RETURNS SETOF vw_topes AS
$BODY$
BEGIN
    RETURN query
        Select * from vw_topes
        where (upper(grupo_practicas) like '%'|| upper(regexp_replace ($1,' ','%', 'g' )) || '%'
         or
         upper(practica_n) like '%'|| upper(regexp_replace ($1,' ','%','g' )) || '%'
        or
        upper(practica) like '%'|| upper($1) || '%' )
        and (fecha_baja is null or fecha_baja>current_date)
        and id_obra_social=COALESCE(idObraSocial, id_obra_social) and id_plan=COALESCE(idPlan, id_plan);

END;

$BODY$
LANGUAGE plpgsql VOLATILE


-------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION crear_codigo_compuesto()
RETURNS trigger AS $$
DECLARE
anio text;
siglas_estado text;
incremental text;
BEGIN
IF NEW.campocodigocompuesto IS NULL OR NEW.campocodigocompuesto = '''' THEN
anio = ( SELECT (date_part(''year'', NOW())::text) );
siglas_estado = ( select siglas from estado where id_estado = NEW.fk_estado );
incremental = ( select to_char( ( max(substring(campocodigocompuesto,7,4))::integer + 1), ''FM0999'')
from obra where anio = substring(campocodigocompuesto,0,5) AND substring(campocodigocompuesto,5,2) = siglas_estado );
NEW.campocodigocompuesto := anio || siglas_estado || incremental;
END IF;
RETURN NEW;
END;
$$LANGUAGE 'plpgsql'