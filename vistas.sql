CREATE OR REPLACE VIEW vw_productos_stock_bajo AS
SELECT p.id_producto, p.codigo, p.nombre, c.nombre AS categoria,
       p.stock, p.stock_minimo, p.precio_unitario
  FROM Productos p
  JOIN Categorias c ON c.id_categoria = p.id_categoria
 WHERE p.activo = TRUE AND p.stock <= p.stock_minimo;

CREATE OR REPLACE VIEW vw_clientes_activos AS
SELECT id_cliente, cedula, nombre, apellidos, email, telefono, fecha_registro
  FROM Clientes
 WHERE activo = TRUE;

CREATE OR REPLACE VIEW vw_facturas_detalle AS
SELECT f.id_factura, f.numero_factura, f.fecha_factura, f.estado,
       cl.nombre || ' ' || cl.apellidos AS cliente,
       p.nombre AS producto, d.cantidad, d.precio_unitario, d.subtotal,
       f.iva, f.total
  FROM Facturas f
  JOIN Clientes cl ON cl.id_cliente = f.id_cliente
  JOIN Detalle_Factura d ON d.id_factura = f.id_factura
  JOIN Productos p ON p.id_producto = d.id_producto;

CREATE OR REPLACE VIEW vw_ventas_por_categoria AS
SELECT c.id_categoria, c.nombre AS categoria,
       SUM(d.cantidad) AS unidades_vendidas,
       SUM(d.subtotal) AS total_vendido
  FROM Detalle_Factura d
  JOIN Productos p   ON p.id_producto = d.id_producto
  JOIN Categorias c  ON c.id_categoria = p.id_categoria
  JOIN Facturas f    ON f.id_factura = d.id_factura
 WHERE f.estado = 'ACTIVA'
 GROUP BY c.id_categoria, c.nombre;

CREATE OR REPLACE VIEW vw_ventas_mensuales AS
SELECT DATE_TRUNC('month', fecha_factura)::DATE AS mes,
       COUNT(*) AS cantidad_facturas,
       SUM(subtotal) AS subtotal,
       SUM(iva) AS iva,
       SUM(total) AS total
  FROM Facturas
 WHERE estado = 'ACTIVA'
 GROUP BY DATE_TRUNC('month', fecha_factura)
 ORDER BY mes DESC;

CREATE OR REPLACE VIEW vw_top_10_productos_vendidos AS
SELECT p.id_producto, p.nombre, p.codigo,
       SUM(d.cantidad) AS unidades_vendidas,
       SUM(d.subtotal) AS total_generado
  FROM Detalle_Factura d
  JOIN Productos p ON p.id_producto = d.id_producto
  JOIN Facturas f  ON f.id_factura = d.id_factura
 WHERE f.estado = 'ACTIVA'
 GROUP BY p.id_producto, p.nombre, p.codigo
 ORDER BY unidades_vendidas DESC
 LIMIT 10;

CREATE OR REPLACE VIEW vw_clientes_mejores_compradores AS
SELECT cl.id_cliente, cl.nombre || ' ' || cl.apellidos AS cliente,
       COUNT(f.id_factura) AS cantidad_facturas,
       SUM(f.total) AS total_comprado
  FROM Clientes cl
  JOIN Facturas f ON f.id_cliente = cl.id_cliente
 WHERE f.estado = 'ACTIVA'
 GROUP BY cl.id_cliente, cliente
 ORDER BY total_comprado DESC;

CREATE OR REPLACE VIEW vw_inventario_valorizado AS
SELECT p.id_producto, p.codigo, p.nombre, c.nombre AS categoria,
       p.stock, p.precio_unitario,
       (p.stock * p.precio_unitario) AS valor_total
  FROM Productos p
  JOIN Categorias c ON c.id_categoria = p.id_categoria
 WHERE p.activo = TRUE
 ORDER BY valor_total DESC;

CREATE OR REPLACE VIEW vw_facturas_anuladas AS
SELECT f.id_factura, f.numero_factura, f.fecha_factura,
       cl.nombre || ' ' || cl.apellidos AS cliente, f.total
  FROM Facturas f
  JOIN Clientes cl ON cl.id_cliente = f.id_cliente
 WHERE f.estado = 'ANULADA';

CREATE OR REPLACE VIEW vw_resumen_diario_ventas AS
SELECT CURRENT_DATE AS fecha,
       COUNT(*) AS cantidad_facturas,
       COALESCE(SUM(subtotal), 0) AS subtotal,
       COALESCE(SUM(iva), 0) AS iva,
       COALESCE(SUM(total), 0) AS total
  FROM Facturas
 WHERE estado = 'ACTIVA'
   AND fecha_factura::DATE = CURRENT_DATE;