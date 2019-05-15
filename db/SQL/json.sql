-- Genera una columna adicional de tipo text[] donde representa la informacion del campo 'tech'
--acompañado de un id.
SELECT p.id, string_to_array(string_agg(elem, ' , '), ',') AS list
FROM profiles p, json_array_elements_text(p.profile -> 'tech') elem
GROUP BY 1; -- "{"postgresql "," ruby "," elixir"}" , {"javascript "," nodejs"}

-- Genera una columna adicional de tipo text donde representa
--la informacion del campo 'name' acompañado de un id.
-- (->) Tipo json, (->>) Realiza el cast
SELECT id, profile ->> 'name' AS name FROM profiles;
-- Obtiene los registros json segun el valor de una llave.
SELECT * FROM profiles WHERE profile ->> 'name' = 'Mario';

-- Trae los tres primeros registros
SELECT * FROM data LIMIT 3;
-- Convierte cada registro con sus campos a formato json.
SELECT row_to_json(data) FROM data LIMIT 3;  -- "{"gender":"Male","height":70.99,"weight":64.48}"
-- Segun los campos que definamos, genera el registro en formato json.
--El inconveniente es que cambia el nombre de los campos por f1 y f2.
SELECT row_to_json(row(gender, height)) FROM data LIMIT 3;
-- Esta vez utiliza un subquery para generar el registro en formato json con los nombres de los campos.
SELECT row_to_json(t) FROM (SELECT gender, height FROM data LIMIT 3) AS t;
-- Ahora, en un solo registro, genera el json con el resultado del subquery.
SELECT array_to_json(array_agg(row_to_json(t))) FROM (SELECT gender, height FROM data LIMIT 3) AS t;
-- [{"gender":"Male","height":70.99},{"gender":"Female","height":69.82},{"gender":"Female","height":70.81}]