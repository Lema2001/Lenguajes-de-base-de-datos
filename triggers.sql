CREATE OR REPLACE FUNCTION trg_fn_validar_stock_antes_insertar()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT fn_validar_stock_suficiente(NEW.id_producto, NEW.cantidad) THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto % (solicitado: %)',
            NEW.id_producto, NEW.cantidad;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_stock_antes_insertar
    BEFORE INSERT ON Detalle_Factura
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_validar_stock_antes_insertar();

CREATE OR REPLACE FUNCTION trg_fn_reducir_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Productos
       SET stock = stock - NEW.cantidad
     WHERE id_producto = NEW.id_producto;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_reducir_stock
    AFTER INSERT ON Detalle_Factura
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_reducir_stock();

CREATE OR REPLACE FUNCTION trg_fn_restaurar_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Productos
       SET stock = stock + OLD.cantidad
     WHERE id_producto = OLD.id_producto;
    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_restaurar_stock
    AFTER DELETE ON Detalle_Factura
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_restaurar_stock();

CREATE OR REPLACE FUNCTION trg_fn_recalcular_totales_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_factura INT;
    v_subtotal   NUMERIC(12,2);
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_id_factura := OLD.id_factura;
    ELSE
        v_id_factura := NEW.id_factura;
    END IF;

    v_subtotal := fn_calcular_subtotal_factura(v_id_factura);

    UPDATE Facturas
       SET subtotal = v_subtotal,
           iva      = fn_calcular_iva(v_subtotal),
           total    = v_subtotal + fn_calcular_iva(v_subtotal)
     WHERE id_factura = v_id_factura;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_recalcular_totales_factura
    AFTER INSERT OR UPDATE OR DELETE ON Detalle_Factura
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_recalcular_totales_factura();

CREATE OR REPLACE FUNCTION trg_fn_prevenir_borrado_cliente()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_cantidad INT;
BEGIN
    SELECT COUNT(*) INTO v_cantidad FROM Facturas WHERE id_cliente = OLD.id_cliente;
    IF v_cantidad > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar físicamente al cliente % porque tiene % factura(s) asociada(s). Use baja lógica (sp_cliente_eliminar).',
            OLD.id_cliente, v_cantidad;
    END IF;
    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_prevenir_borrado_cliente
    BEFORE DELETE ON Clientes
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_prevenir_borrado_cliente();