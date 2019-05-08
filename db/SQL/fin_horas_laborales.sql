CREATE OR REPLACE FUNCTION fn_horas_laborales(TIMESTAMP, TIMESTAMP) RETURNS INTERVAL
    AS
        $$
            /**
            *   BRYAN CALERO
            */
            WITH t (t_id, t_start, t_end) AS (
                VALUES
                    (1,  $1, $2)
            )
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
            SELECT
                justify_interval(COALESCE(p.work_interval, 0::INT * INTERVAL '1h'))
                /*EXTRACT(epoch FROM fn_horas_laborales('2019-03-04 08:00:00'::TIMESTAMP, '2019-04-05 12:00:00'::TIMESTAMP)) / 3600*/ /*PARA OBTENER LAS HORAS EN NUMEROS*/
            FROM data_procesa p;
        $$
    LANGUAGE SQL
    IMMUTABLE
;