CREATE OR REPLACE FUNCTION trigg_shift_cost() RETURNS TRIGGER AS $costo_turno$
  /*
   * Author: Jhonny Stiven Agudelo Tenorio
   * Purpose: Costo ruta
   * statement in PostgreSQL.
   */
  DECLARE
  data_costo_turno RECORD;
  BEGIN
  WITH select_turno AS (
			SELECT *
				INTO
				data_costo_turno
				FROM costo_turnos
				WHERE	TRUE
				AND id_turno = OLD.id_turno
			),
		 data_turno AS (
			SELECT *
				FROM costo_turnos
				WHERE TRUE
				AND id_turno = OLD.id_turno
			),

				 insert_data AS (
				-- IF NOT FOUND
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
				        (CASE WHEN t.positivo >= t_rt.num_positivo
				            THEN (t.positivo * t_rt.valor_ruta) * t_rt.costo
				          ELSE 0 END ) END AS costo_positivo

				     ,CASE WHEN r_t.id_ayuda = aa_v.id_ayuda THEN t.bea_bruto - aa_v.precio ELSE bea_bruto END AS bea_neto

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
				    AND t.id_turno = NEW.id_turno
				    AND id_costo_turno IS NULL
				   ),
				update_date AS (
					UPDATE costo_turno SET
						costo_positivo = d_t.costo_positivo
						,bea_neto = d_t.bea_neto
						FROM data_turno d_t
							WHERE TRUE
							AND id_costo_turno IS NULL
					)
				SELECT *
					FROM insert_data
						UNION
				SELECT *
					FROM update_date;

		  RETURN NEW;
		  END;
	  $costo_turno$ LANGUAGE plpgsql VOLATILE;




