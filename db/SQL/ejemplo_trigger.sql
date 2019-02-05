    -- Function: im_detalle_1_actualiza_ingreso()

    -- DROP FUNCTION im_detalle_1_actualiza_ingreso();

    CREATE OR REPLACE FUNCTION 1() RETURNS trigger AS
    $BODY$
    DECLARE
    -- Declaramos las variables con el mismo tipo del definido en la tabla
    iva_5 ingreso_mercaderia.im_impuesto_5%TYPE;
    iva_10 ingreso_mercaderia.im_impuesto_10%TYPE;
    curtime        timestamp;
    fecha_compra   date;
    BEGIN
    -- Esta es la forma correcta de obtener el "ahora"
    -- segun la documentacion oficial
    -- url: http://www.postgresql.org/docs/8.2/static/plpgsql-expressions.html
    curtime := 'now';

    -- Estamos insertando el registro?
    IF TG_OP = 'INSERT' THEN
    -- Obtenemos los totales de IVA 5 y 10%
    SELECT
    SUM(CASE WHEN imd_porc_impuesto = 5 THEN imd_impuesto ELSE 0 END) AS porc_5,
    SUM(CASE WHEN imd_porc_impuesto = 10 THEN imd_impuesto ELSE 0 END) AS porc_10
    INTO iva_5, iva_10
    FROM im_detalle
    WHERE idingmercaderia = NEW.idingmercaderia;

    -- obtenemos; la fecha de compra de la tabla cabecera
    SELECT im_fecha_compra
    INTO fecha_compra
    FROM ingreso_mercaderia
    WHERE idingmercaderia = NEW.idingmercaderia;

    -- actualizamos la tabla de arti­culo con la fecha de la nueva compra
    UPDATE articulo
    SET art_f_ultcompra = fecha_compra
    WHERE idarticulo = NEW.idarticulo;

    -- ahora actualizamos los estadi­sticos del ariÃ­culo
    PERFORM fn_actualizar_estadisticos_articulo(NEW.idarticulo);

    -- Actualizamos la tabla de ingreso de mercaderi­as sumando los totales
    UPDATE ingreso_mercaderia
    SET
    im_subtotal = im_subtotal + NEW.imd_subtotal,
    im_descuentos = im_descuentos + NEW.imd_descuento,
    im_impuesto_5 = iva_5,
    im_impuesto_10 = iva_10,
    im_impuestos = iva_5 + iva_10,
    im_total = im_total + NEW.imd_precio_final
    WHERE idingmercaderia = NEW.idingmercaderia;

    -- Actualizamos la tabla de arti­culo con el nuevo precio de compra (costo)
    -- Si el precio de compra es 0 entonces no hacemos nada
    -- INFO: hay un trigger sobre arti­culo que guarda un historico de variaciones de costo en historico_precios
    IF NEW.imd_precio_compra <> 0 THEN
    UPDATE articulo
    SET art_costo = NEW.imd_precio_compra,
    art_f_act = curtime,
    art_modif_por = current_user
    WHERE idarticulo = NEW.idarticulo;
    END IF;

    RETURN NEW;
    END IF;

    -- Estamos actualizando el registro?
    IF TG_OP = 'UPDATE' THEN
    -- Obtenemos los totales de IVA 5 y 10%
    SELECT
    SUM(CASE WHEN imd_porc_impuesto = 5 THEN imd_impuesto ELSE 0 END) AS porc_5,
    SUM(CASE WHEN imd_porc_impuesto = 10 THEN imd_impuesto ELSE 0 END) AS porc_10
    INTO iva_5, iva_10
    FROM im_detalle
    WHERE idingmercaderia = NEW.idingmercaderia;

    -- obtenemos la fecha de compra de la tabla cabecera
    SELECT im_fecha_compra
    INTO fecha_compra
    FROM ingreso_mercaderia
    WHERE idingmercaderia = NEW.idingmercaderia;

    -- actualizamos la tabla de arti­culo con la fecha de la nueva compra
    UPDATE articulo
    SET art_f_ultcompra = fecha_compra
    WHERE idarticulo = NEW.idarticulo;

    -- ahora actualizamos los estadi­sticos del arti­culo
    PERFORM fn_actualizar_estadisticos_articulo(NEW.idarticulo);

    -- Actualizamos la tabla de ingreso de mercaderi­as, primero restamos los totales
    -- anteriores, luego sumamos los nuevos totales
    UPDATE ingreso_mercaderia
    SET
    im_subtotal = (im_subtotal - OLD.imd_subtotal) + NEW.imd_subtotal,
    im_descuentos = (im_descuentos - OLD.imd_descuento) + NEW.imd_descuento,
    im_impuesto_5 = iva_5,
    im_impuesto_10 = iva_10,
    im_impuestos = iva_5 + iva_10,
    im_total = (im_total - OLD.imd_precio_final) + NEW.imd_precio_final
    WHERE idingmercaderia = NEW.idingmercaderia;

    -- Actualizamos la tabla de arti­culo con el nuevo precio de compra (costo)
    -- Si el precio de compra es 0 entonces no hacemos nada
    -- INFO: hay un trigger sobre arti­culo que guarda un historico de variaciones de costo en historico_precios
    IF NEW.imd_precio_compra <> 0 THEN
    UPDATE articulo
    SET art_costo = NEW.imd_precio_compra,
    art_f_act = curtime,
    art_modif_por = current_user
    WHERE idarticulo = NEW.idarticulo;
    END IF;

    RETURN NEW;
    END IF;

    -- Estamos borrando el registro
    IF TG_OP = 'DELETE' THEN
    -- Es IVA 5%?
    IF OLD.imd_porc_impuesto = 5 THEN
    iva_5 := OLD.imd_impuesto;
    ELSE
    iva_5 := 0;
    END IF;

    -- Es IVA 10%?
    IF OLD.imd_porc_impuesto = 10 THEN
    iva_10 := OLD.imd_impuesto;
    ELSE
    iva_10 := 0;
    END IF;

    -- ahora actualizamos
    -- re-calculamos los estadi­sticos para el arti­culo ya sin el
    -- precio que estamos borrando ahora
    PERFORM fn_actualizar_estadisticos_articulo(OLD.idarticulo);

    -- Actualizamos la tabla de ingreso de mercaderi­as descontando los totales
    UPDATE ingreso_mercaderia SET
    im_subtotal = im_subtotal - OLD.imd_subtotal,
    im_descuentos = im_descuentos - OLD.imd_descuento,
    im_impuesto_5 = im_impuesto_5 - iva_5,
    im_impuesto_10 = im_impuesto_10 - iva_10,
    im_impuestos = im_impuestos  - OLD.imd_impuesto,
    im_total = im_total - OLD.imd_precio_final
    WHERE idingmercaderia = OLD.idingmercaderia;

    RETURN OLD;
    END IF;
    END;
    $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;
    ALTER FUNCTION im_detalle_1_actualiza_ingreso()
    OWNER TO everdaniel;
