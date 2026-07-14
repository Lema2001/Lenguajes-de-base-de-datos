CREATE OR REPLACE PROCEDURE sp_categoria_insertar(
    IN  p_nombre        VARCHAR,
    IN  p_descripcion   VARCHAR,
    OUT o_id_categoria  INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Categorias(nombre, descripcion)
    VALUES (p_nombre, p_descripcion)
    RETURNING id_categoria INTO o_id_categoria;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_categoria_actualizar(
    IN p_id_categoria INT,
    IN p_nombre       VARCHAR,
    IN p_descripcion  VARCHAR,
    IN p_activo       BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Categorias
       SET nombre = p_nombre,
           descripcion = p_descripcion,
           activo = p_activo
     WHERE id_categoria = p_id_categoria;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La categoría % no existe', p_id_categoria;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_categoria_eliminar(
    IN p_id_categoria INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Categorias SET activo = FALSE WHERE id_categoria = p_id_categoria;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'La categoría % no existe', p_id_categoria;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_categoria_obtener(
    IN  p_id_categoria INT,
    OUT o_id_categoria INT,
    OUT o_nombre       VARCHAR,
    OUT o_descripcion  VARCHAR,
    OUT o_activo       BOOLEAN,
    OUT o_fecha        TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT id_categoria, nombre, descripcion, activo, fecha_creacion
      INTO o_id_categoria, o_nombre, o_descripcion, o_activo, o_fecha
      FROM Categorias
     WHERE id_categoria = p_id_categoria;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_categoria_listar(
    INOUT o_cursor REFCURSOR DEFAULT 'cur_categorias'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
        SELECT id_categoria, nombre, descripcion, activo, fecha_creacion
          FROM Categorias
         ORDER BY nombre;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_cliente_insertar(
    IN  p_cedula     VARCHAR,
    IN  p_nombre     VARCHAR,
    IN  p_apellidos  VARCHAR,
    IN  p_email      VARCHAR,
    IN  p_telefono   VARCHAR,
    IN  p_direccion  VARCHAR,
    OUT o_id_cliente INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT fn_validar_cedula(p_cedula) THEN
        RAISE EXCEPTION 'Cédula inválida: %', p_cedula;
    END IF;
    IF NOT fn_validar_email(p_email) THEN
        RAISE EXCEPTION 'Correo inválido: %', p_email;
    END IF;

    INSERT INTO Clientes(cedula, nombre, apellidos, email, telefono, direccion)
    VALUES (p_cedula, p_nombre, p_apellidos, p_email, p_telefono, p_direccion)
    RETURNING id_cliente INTO o_id_cliente;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_cliente_actualizar(
    IN p_id_cliente INT,
    IN p_nombre     VARCHAR,
    IN p_apellidos  VARCHAR,
    IN p_email      VARCHAR,
    IN p_telefono   VARCHAR,
    IN p_direccion  VARCHAR,
    IN p_activo     BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT fn_validar_email(p_email) THEN
        RAISE EXCEPTION 'Correo inválido: %', p_email;
    END IF;

    UPDATE Clientes
       SET nombre = p_nombre,
           apellidos = p_apellidos,
           email = p_email,
           telefono = p_telefono,
           direccion = p_direccion,
           activo = p_activo
     WHERE id_cliente = p_id_cliente;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El cliente % no existe', p_id_cliente;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_cliente_eliminar(
    IN p_id_cliente INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Clientes SET activo = FALSE WHERE id_cliente = p_id_cliente;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El cliente % no existe', p_id_cliente;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_cliente_obtener(
    IN  p_id_cliente   INT,
    OUT o_id_cliente   INT,
    OUT o_cedula       VARCHAR,
    OUT o_nombre       VARCHAR,
    OUT o_apellidos    VARCHAR,
    OUT o_email        VARCHAR,
    OUT o_telefono     VARCHAR,
    OUT o_direccion    VARCHAR,
    OUT o_activo       BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT id_cliente, cedula, nombre, apellidos, email, telefono, direccion, activo
      INTO o_id_cliente, o_cedula, o_nombre, o_apellidos, o_email, o_telefono, o_direccion, o_activo
      FROM Clientes
     WHERE id_cliente = p_id_cliente;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_cliente_listar(
    INOUT o_cursor REFCURSOR DEFAULT 'cur_clientes'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
        SELECT id_cliente, cedula, nombre, apellidos, email, telefono, direccion,
               fecha_registro, activo
          FROM Clientes
         ORDER BY apellidos, nombre;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_producto_insertar(
    IN  p_codigo          VARCHAR,
    IN  p_nombre          VARCHAR,
    IN  p_descripcion     VARCHAR,
    IN  p_id_categoria    INT,
    IN  p_precio_unitario NUMERIC,
    IN  p_stock           INT,
    IN  p_stock_minimo    INT,
    OUT o_id_producto     INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Productos(codigo, nombre, descripcion, id_categoria,
                           precio_unitario, stock, stock_minimo)
    VALUES (p_codigo, p_nombre, p_descripcion, p_id_categoria,
            p_precio_unitario, p_stock, p_stock_minimo)
    RETURNING id_producto INTO o_id_producto;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_producto_actualizar(
    IN p_id_producto     INT,
    IN p_nombre          VARCHAR,
    IN p_descripcion     VARCHAR,
    IN p_id_categoria    INT,
    IN p_precio_unitario NUMERIC,
    IN p_stock_minimo    INT,
    IN p_activo          BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Productos
       SET nombre = p_nombre,
           descripcion = p_descripcion,
           id_categoria = p_id_categoria,
           precio_unitario = p_precio_unitario,
           stock_minimo = p_stock_minimo,
           activo = p_activo
     WHERE id_producto = p_id_producto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El producto % no existe', p_id_producto;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_producto_eliminar(
    IN p_id_producto INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Productos SET activo = FALSE WHERE id_producto = p_id_producto;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El producto % no existe', p_id_producto;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_producto_obtener(
    IN  p_id_producto     INT,
    OUT o_id_producto     INT,
    OUT o_codigo          VARCHAR,
    OUT o_nombre          VARCHAR,
    OUT o_descripcion     VARCHAR,
    OUT o_id_categoria    INT,
    OUT o_precio_unitario NUMERIC,
    OUT o_stock           INT,
    OUT o_stock_minimo    INT,
    OUT o_activo          BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT id_producto, codigo, nombre, descripcion, id_categoria,
           precio_unitario, stock, stock_minimo, activo
      INTO o_id_producto, o_codigo, o_nombre, o_descripcion, o_id_categoria,
           o_precio_unitario, o_stock, o_stock_minimo, o_activo
      FROM Productos
     WHERE id_producto = p_id_producto;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_producto_listar(
    INOUT o_cursor REFCURSOR DEFAULT 'cur_productos'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
        SELECT p.id_producto, p.codigo, p.nombre, c.nombre AS categoria,
               p.precio_unitario, p.stock, p.stock_minimo, p.activo
          FROM Productos p
          JOIN Categorias c ON c.id_categoria = p.id_categoria
         ORDER BY p.nombre;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_factura_insertar(
    IN  p_id_cliente  INT,
    OUT o_id_factura  INT,
    OUT o_numero      VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT fn_cliente_existe(p_id_cliente) THEN
        RAISE EXCEPTION 'El cliente % no existe o está inactivo', p_id_cliente;
    END IF;

    o_numero := fn_numero_factura_siguiente();

    INSERT INTO Facturas(numero_factura, id_cliente)
    VALUES (o_numero, p_id_cliente)
    RETURNING id_factura INTO o_id_factura;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_factura_actualizar(
    IN p_id_factura INT,
    IN p_estado     VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Facturas
       SET estado = p_estado
     WHERE id_factura = p_id_factura;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La factura % no existe', p_id_factura;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_factura_eliminar(
    IN p_id_factura INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Detalle_Factura WHERE id_factura = p_id_factura;

    UPDATE Facturas
       SET estado = 'ANULADA'
     WHERE id_factura = p_id_factura;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La factura % no existe', p_id_factura;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_factura_obtener(
    IN  p_id_factura     INT,
    OUT o_id_factura     INT,
    OUT o_numero_factura VARCHAR,
    OUT o_id_cliente     INT,
    OUT o_fecha_factura  TIMESTAMP,
    OUT o_subtotal       NUMERIC,
    OUT o_iva            NUMERIC,
    OUT o_total          NUMERIC,
    OUT o_estado         VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT id_factura, numero_factura, id_cliente, fecha_factura,
           subtotal, iva, total, estado
      INTO o_id_factura, o_numero_factura, o_id_cliente, o_fecha_factura,
           o_subtotal, o_iva, o_total, o_estado
      FROM Facturas
     WHERE id_factura = p_id_factura;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_factura_listar(
    INOUT o_cursor REFCURSOR DEFAULT 'cur_facturas'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
        SELECT f.id_factura, f.numero_factura,
               c.nombre || ' ' || c.apellidos AS cliente,
               f.fecha_factura, f.subtotal, f.iva, f.total, f.estado
          FROM Facturas f
          JOIN Clientes c ON c.id_cliente = f.id_cliente
         ORDER BY f.fecha_factura DESC;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_detalle_insertar(
    IN  p_id_factura  INT,
    IN  p_id_producto INT,
    IN  p_cantidad    INT,
    OUT o_id_detalle  INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_precio NUMERIC(12,2);
BEGIN
    SELECT precio_unitario INTO v_precio
      FROM Productos
     WHERE id_producto = p_id_producto AND activo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El producto % no existe o está inactivo', p_id_producto;
    END IF;

    INSERT INTO Detalle_Factura(id_factura, id_producto, cantidad, precio_unitario, subtotal)
    VALUES (p_id_factura, p_id_producto, p_cantidad, v_precio, v_precio * p_cantidad)
    RETURNING id_detalle INTO o_id_detalle;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_detalle_actualizar(
    IN p_id_detalle INT,
    IN p_cantidad   INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_producto  INT;
    v_cant_actual  INT;
    v_precio       NUMERIC(12,2);
    v_diferencia   INT;
BEGIN
    SELECT id_producto, cantidad, precio_unitario
      INTO v_id_producto, v_cant_actual, v_precio
      FROM Detalle_Factura
     WHERE id_detalle = p_id_detalle;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El detalle % no existe', p_id_detalle;
    END IF;

    v_diferencia := p_cantidad - v_cant_actual; 

    IF NOT fn_validar_stock_suficiente(v_id_producto, v_diferencia) THEN
        RAISE EXCEPTION 'Stock insuficiente para aumentar la cantidad del producto %', v_id_producto;
    END IF;

    UPDATE Productos SET stock = stock - v_diferencia WHERE id_producto = v_id_producto;

    UPDATE Detalle_Factura
       SET cantidad = p_cantidad,
           subtotal = v_precio * p_cantidad
     WHERE id_detalle = p_id_detalle;
END;
$$;

-- Elimina una línea de detalle; el trigger AFTER DELETE repone

CREATE OR REPLACE PROCEDURE sp_detalle_eliminar(
    IN p_id_detalle INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Detalle_Factura WHERE id_detalle = p_id_detalle;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El detalle % no existe', p_id_detalle;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_detalle_obtener(
    IN  p_id_detalle      INT,
    OUT o_id_detalle      INT,
    OUT o_id_factura      INT,
    OUT o_id_producto     INT,
    OUT o_cantidad        INT,
    OUT o_precio_unitario NUMERIC,
    OUT o_subtotal        NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT id_detalle, id_factura, id_producto, cantidad, precio_unitario, subtotal
      INTO o_id_detalle, o_id_factura, o_id_producto, o_cantidad, o_precio_unitario, o_subtotal
      FROM Detalle_Factura
     WHERE id_detalle = p_id_detalle;
END;
$$;

-- Lista las líneas de una factura específica.
CREATE OR REPLACE PROCEDURE sp_detalle_listar(
    IN    p_id_factura INT,
    INOUT o_cursor     REFCURSOR DEFAULT 'cur_detalle'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN o_cursor FOR
        SELECT d.id_detalle, d.id_factura, p.nombre AS producto,
               d.cantidad, d.precio_unitario, d.subtotal
          FROM Detalle_Factura d
          JOIN Productos p ON p.id_producto = d.id_producto
         WHERE d.id_factura = p_id_factura
         ORDER BY d.id_detalle;
END;
$$;