CREATE OR REPLACE FUNCTION fn_tasa_iva()
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT 0.13::NUMERIC;
$$;

CREATE OR REPLACE FUNCTION fn_stock_disponible(p_id_producto INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INT;
BEGIN
    SELECT stock INTO v_stock FROM Productos WHERE id_producto = p_id_producto;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Producto % no existe', p_id_producto;
    END IF;
    RETURN v_stock;
END;
$$;

CREATE OR REPLACE FUNCTION fn_validar_stock_suficiente(p_id_producto INT, p_cantidad INT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INT;
BEGIN
    SELECT stock INTO v_stock FROM Productos WHERE id_producto = p_id_producto;
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    RETURN v_stock >= p_cantidad;
END;
$$;

CREATE OR REPLACE FUNCTION fn_valor_total_inventario()
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(14,2);
BEGIN
    SELECT COALESCE(SUM(stock * precio_unitario), 0)
      INTO v_total
      FROM Productos
     WHERE activo = TRUE;
    RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION fn_verificar_stock_minimo()
RETURNS TABLE(id_producto INT, nombre VARCHAR, stock INT, stock_minimo INT)
LANGUAGE plpgsql
AS $$
DECLARE
    cur_bajo_stock CURSOR FOR
        SELECT p.id_producto, p.nombre, p.stock, p.stock_minimo
          FROM Productos p
         WHERE p.activo = TRUE
           AND p.stock <= p.stock_minimo;
    v_reg RECORD;
BEGIN
    OPEN cur_bajo_stock;
    LOOP
        FETCH cur_bajo_stock INTO v_reg;
        EXIT WHEN NOT FOUND;

        id_producto  := v_reg.id_producto;
        nombre       := v_reg.nombre;
        stock        := v_reg.stock;
        stock_minimo := v_reg.stock_minimo;
        RETURN NEXT;
    END LOOP;
    CLOSE cur_bajo_stock;
END;
$$;

CREATE OR REPLACE FUNCTION fn_ajustar_stock(p_id_producto INT, p_cantidad INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_nuevo_stock INT;
BEGIN
    UPDATE Productos
       SET stock = stock + p_cantidad
     WHERE id_producto = p_id_producto
     RETURNING stock INTO v_nuevo_stock;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Producto % no existe', p_id_producto;
    END IF;
    IF v_nuevo_stock < 0 THEN
        RAISE EXCEPTION 'El ajuste dejaría stock negativo en el producto %', p_id_producto;
    END IF;
    RETURN v_nuevo_stock;
END;
$$;

CREATE OR REPLACE FUNCTION fn_calcular_subtotal_factura(p_id_factura INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_subtotal NUMERIC(12,2);
BEGIN
    SELECT COALESCE(SUM(subtotal), 0) INTO v_subtotal
      FROM Detalle_Factura
     WHERE id_factura = p_id_factura;
    RETURN v_subtotal;
END;
$$;

CREATE OR REPLACE FUNCTION fn_calcular_iva(p_monto NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN ROUND(p_monto * fn_tasa_iva(), 2);
END;
$$;

CREATE OR REPLACE FUNCTION fn_calcular_total_factura(p_id_factura INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_subtotal NUMERIC(12,2);
BEGIN
    v_subtotal := fn_calcular_subtotal_factura(p_id_factura);
    RETURN v_subtotal + fn_calcular_iva(v_subtotal);
END;
$$;

CREATE OR REPLACE FUNCTION fn_total_ventas_por_cliente(p_id_cliente INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(14,2);
BEGIN
    SELECT COALESCE(SUM(total), 0) INTO v_total
      FROM Facturas
     WHERE id_cliente = p_id_cliente AND estado = 'ACTIVA';
    RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION fn_total_ventas_periodo(p_fecha_inicio DATE, p_fecha_fin DATE)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(14,2);
BEGIN
    SELECT COALESCE(SUM(total), 0) INTO v_total
      FROM Facturas
     WHERE estado = 'ACTIVA'
       AND fecha_factura::DATE BETWEEN p_fecha_inicio AND p_fecha_fin;
    RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION fn_numero_factura_siguiente()
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_siguiente INT;
BEGIN
    SELECT COALESCE(MAX(id_factura), 0) + 1 INTO v_siguiente FROM Facturas;
    RETURN 'FAC-' || LPAD(v_siguiente::TEXT, 6, '0');
END;
$$;

CREATE OR REPLACE FUNCTION fn_producto_mas_vendido()
RETURNS TABLE(id_producto INT, nombre VARCHAR, unidades_vendidas BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    cur_ventas CURSOR FOR
        SELECT p.id_producto, p.nombre, SUM(d.cantidad) AS unidades
          FROM Detalle_Factura d
          JOIN Productos p ON p.id_producto = d.id_producto
          JOIN Facturas f  ON f.id_factura = d.id_factura
         WHERE f.estado = 'ACTIVA'
         GROUP BY p.id_producto, p.nombre
         ORDER BY unidades DESC;
    v_reg RECORD;
BEGIN
    OPEN cur_ventas;
    FETCH cur_ventas INTO v_reg; 
    CLOSE cur_ventas;

    IF v_reg IS NULL THEN
        RETURN;
    END IF;

    id_producto        := v_reg.id_producto;
    nombre             := v_reg.nombre;
    unidades_vendidas  := v_reg.unidades;
    RETURN NEXT;
END;
$$;

CREATE OR REPLACE FUNCTION fn_validar_cedula(p_cedula VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN p_cedula ~ '^[0-9]{9,12}$';
END;
$$;

CREATE OR REPLACE FUNCTION fn_validar_email(p_email VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN p_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$;

CREATE OR REPLACE FUNCTION fn_cliente_existe(p_id_cliente INT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM Clientes WHERE id_cliente = p_id_cliente AND activo = TRUE
    ) INTO v_existe;
    RETURN v_existe;
END;
$$;
