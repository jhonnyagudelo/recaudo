CREATE OR REPLACE FUNCTION trigg_shift_cost() RETURNS TRIGGER AS $costo_turno$
DECLARE
data_costo_turno RECORD;
BEGIN

--terminar el with y preguntar que hacer con el

	SELECT *
		INTO
		data_costo_turno
		FROM costo_turnos
		WHERE	TRUE
		AND id_turno = OLD.id_costo_turno;


  WITH data_turno AS (
	   SELECT *
		  FROM costo_turnos
		  WHERE TRUE
		  AND id_turno = OLD.id_turno
	)

  , insert_data AS (
  		INSERT INTO costo_turnos (
		    id_turno
		    ,costo_positivo
		    ,bea_neto
		    -- ,bea_neto_total
		    ,vehiculo
		    ,numero_turno
		    )
		    SELECT
		     NEW.id_turno
		     ,CASE
		        WHEN r_t.tarifa_positivo_id = t_rt.tarifa_positivo_id THEN
		        (CASE WHEN dc_t.positivo >= t_rt.num_positivo
		            THEN (dc_t.positivo * t_rt.valor_ruta) * t_rt.costo
		          ELSE 0 END ) END AS costo_positivo

		     ,CASE WHEN r_t.id_ayuda = aa_v.id_ayuda THEN t.bea_bruto - aa_v.precio ELSE bea_bruto END AS bea_neto

		     ,dc_t.vehiculo
		     ,dc_t.numero_turno
		    FROM data_costo_turno dc_t
		    INNER JOIN rodamientos rd_t
		      ON dc_t.rodamiento_id = rd_t.id_rodamiento
		    INNER JOIN vehiculos v_r
		      ON  v_r.numero_interno = rd_t.numero_interno
		    INNER JOIN rutas r_t
		      ON dc_t.id_ruta = r_t.id_ruta
		    LEFT JOIN ayuda_auxiliar aa_v
		      ON  r_t.id_ayuda = aa_v.id_ayuda
		    LEFT JOIN  tarifa_positivos t_rt
		      ON r_t.tarifa_positivo_id =  t_rt.tarifa_positivo_id
		    WHERE TRUE
		    AND dc_t.id_turno = NEW.id_turno
		    AND id_costo_turno IS NULL
		   )

	, update_date AS (
			UPDATE costo_turno SET
				costo_positivo = d_t.costo_positivo
				,bea_neto = d_t.bea_neto
				FROM data_turno d_t
					WHERE TRUE
					AND id_costo_turno IS NOT NULL
			)

  , choose_data (_insert, _update) AS (
      SELECT FROM insert_data
        UNION
  		SELECT * FROM update_date
    )

  , process AS (
    SELECT
      COALESCE()

    )


  RETURN NEW;
  END;
$costo_turno$ LANGUAGE plpgsql VOLATILE;


  	-- IF NOT FOUND THEN


---------------------------------------------

            , var (dia, v_start, v_end) AS (
                SELECT gs.dia, '08:00:00'::TIME, '18:00:00'::TIME FROM generate_series (1, 5) gs (dia) /* LUNES - VIERNES */
                UNION ALL
                SELECT gs.dia, '08:00:00'::TIME, '12:00:00'::TIME FROM generate_series (6, 6) gs (dia) /* SABADO */
            )

            , data_procesa AS (
                SELECT
                    (COALESCE(h.h, 0::INT * INTERVAL '1h')
                            - CASE
                                    WHEN TRUE
                                            AND t.t_start::TIME > v_s.v_start
                                            AND t.t_start::TIME < v_s.v_end
                                        THEN t.t_start - DATE_TRUNC('hour', t.t_start)
                                    ELSE '0'::INTERVAL
                                    END
                            + CASE
                                    WHEN TRUE
                                            AND t.t_end::TIME > v_e.v_start
                                            AND t.t_end::TIME < v_e.v_end
                                        THEN t.t_end - DATE_TRUNC('hour', t.t_end)
                                    ELSE '0'::INTERVAL
                                    END)::INTERVAL
                        AS work_interval
                FROM t
                    INNER JOIN var v_s ON v_s.dia = EXTRACT(ISODOW FROM t.t_start)
                    INNER JOIN var v_e ON v_e.dia = EXTRACT(ISODOW FROM t.t_end)
                    LEFT JOIN (
                            SELECT
                                sub.t_id
                                , COUNT(*)::INT * INTERVAL '1h' AS h
                            FROM (
                                    SELECT
                                        t.t_id
                                        , generate_series(
                                                DATE_TRUNC('hour', t.t_start)
                                                , DATE_TRUNC('hour', t.t_end)
                                                    - INTERVAL '1h'
                                                , INTERVAL '1h')
                                            AS h
                                    FROM t
                                ) sub
                                INNER JOIN var v ON v.dia = (SELECT EXTRACT(ISODOW FROM sub.h))
                            WHERE TRUE
                                AND sub.h::TIME
                                    BETWEEN v.v_start
                                        AND v.v_end - INTERVAL '1h'
                            GROUP  BY
                                1
                            )
                        h USING (t_id)
                WHERE TRUE
                    AND t.t_start < t.t_end
                ORDER  BY 1
            )

















CREATE OR REPLACE FUNCTION trigg_shift_cost() RETURNS TRIGGER AS $costo_turno$
  /*
   * Author: Jhonny Stiven Agudelo Tenorio
   * Purpose: Costo ruta
   * statement in PostgreSQL.
   */
  DECLARE
  data_costo_turno RECORD;
  BEGIN
      SELECT *
        INTO
        data_costo_turno
        FROM costo_turnos
        WHERE TRUE
        AND id_turno = OLD.id_turno ;

          INSERT INTO costo_turnos (
            id_turno
            ,costo_positivo
            ,bea_neto
            ,bea_neto_total
            ,vehiculo
            ,numero_turno
            )
            SELECT
             NEW.id_turno
             ,CASE
                WHEN r_t.tarifa_positivo_id = t_rt.tarifa_positivo_id THEN
                (CASE WHEN t.positivo >= t_rt.num_positivo
                    THEN (t.positivo * t_rt.valor_ruta) * t_rt.costo
                  ELSE 0 END ) END AS costo_positivo

             ,CASE

                WHEN r_t.id_ayuda = aa_v.id_ayuda THEN t.bea_bruto - aa_v.precio ELSE bea_bruto END AS bea_neto

             -- ,CASE
             --    WHEN r_t.tarifa_positivo_id = t_rt.tarifa_positivo_id
             --    THEN
             --      (CASE
             --        WHEN t.positivo >= t_rt.num_positivo
             --          THEN (t.positivo * t_rt.valor_ruta) * t_rt.costo
             --        ELSE 0 END ) CASE
             --                      WHEN r_t.id_ayuda = aa_v.id_ayuda THEN t.bea_bruto - aa_v.precio
             --                    ELSE bea_bruto END


             -- ,bea_neto_total = (bea_neto + costo_positivo)::DOUBLE PRECISION
             --colocar los 2 otras ves

             ,t.vehiculo
             ,t.numero_turno
            FROM turnos t
            INNER JOIN rodamientos rd_t
              ON t.rodamiento_id = rd_t.id_rodamiento
            INNER JOIN vehiculos v_r
              ON  v_r.numero_interno = rd_t.numero_interno
            INNER JOIN rutas r_t
              ON t.id_ruta = r_t.id_ruta
            LEFT JOIN ayuda_auxiliar aa_v
              ON  r_t.id_ayuda = aa_v.id_ayuda
            LEFT JOIN  tarifa_positivos t_rt
              ON r_t.tarifa_positivo_id =  t_rt.tarifa_positivo_id
            WHERE TRUE
            AND t.id_turno = NEW.id_turno;

            ELSE
              UPDATE
        END IF;
      RETURN NEW;
      END;
    $costo_turno$ LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER after_cost_turn
  AFTER UPDATE ON turnos
  FOR EACH ROW
  EXECUTE PROCEDURE trigg_shift_cost();
