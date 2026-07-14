import psycopg
from dataclasses import dataclass
from datetime import date
from typing import Optional

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "techstore_cr",
    "user": "postgres",
    "password": "postgres",
}

def get_connection() -> psycopg.Connection:
    """Crea y retorna una nueva conexión a PostgreSQL."""
    return psycopg.connect(**DB_CONFIG)

@dataclass
class Cliente:
    id_cliente: int
    cedula: str
    nombre: str
    apellidos: str
    email: str
    telefono: Optional[str]
    direccion: Optional[str]
    activo: bool

def categoria_insertar(nombre: str, descripcion: str) -> int:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_categoria_insertar(%s, %s, NULL)", (nombre, descripcion)
            )
            id_categoria = cur.fetchone()[0]
        conn.commit()
        return id_categoria

def categoria_actualizar(id_categoria: int, nombre: str, descripcion: str, activo: bool) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_categoria_actualizar(%s, %s, %s, %s)",
                (id_categoria, nombre, descripcion, activo),
            )
        conn.commit()

def categoria_eliminar(id_categoria: int) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_categoria_eliminar(%s)", (id_categoria,))
        conn.commit()

def categoria_obtener(id_categoria: int) -> Optional[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_categoria_obtener(%s, NULL, NULL, NULL, NULL, NULL)",
                (id_categoria,),
            )
            return cur.fetchone()

def categoria_listar() -> list[tuple]:
    """Ejemplo de consumo de un procedimiento que abre un
    REFCURSOR: se llama al procedimiento y luego se hace FETCH
    ALL sobre el cursor con nombre, dentro de la misma
    transacción (autocommit=False es el modo por defecto)."""
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_categoria_listar('cur_categorias')")
            cur.execute("FETCH ALL FROM cur_categorias")
            filas = cur.fetchall()
        conn.commit()
        return filas

def cliente_insertar(cedula, nombre, apellidos, email, telefono, direccion) -> int:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_cliente_insertar(%s, %s, %s, %s, %s, %s, NULL)",
                (cedula, nombre, apellidos, email, telefono, direccion),
            )
            return cur.fetchone()[0]
        
def cliente_actualizar(id_cliente, nombre, apellidos, email, telefono, direccion, activo) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_cliente_actualizar(%s, %s, %s, %s, %s, %s, %s)",
                (id_cliente, nombre, apellidos, email, telefono, direccion, activo),
            )
        conn.commit()

def cliente_eliminar(id_cliente: int) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_cliente_eliminar(%s)", (id_cliente,))
        conn.commit()

def cliente_obtener(id_cliente: int) -> Optional[Cliente]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_cliente_obtener(%s, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)",
                (id_cliente,),
            )
            fila = cur.fetchone()
            return Cliente(*fila) if fila else None

def cliente_listar() -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_cliente_listar('cur_clientes')")
            cur.execute("FETCH ALL FROM cur_clientes")
            filas = cur.fetchall()
        conn.commit()
        return filas

def producto_insertar(codigo, nombre, descripcion, id_categoria, precio, stock, stock_min) -> int:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_producto_insertar(%s, %s, %s, %s, %s, %s, %s, NULL)",
                (codigo, nombre, descripcion, id_categoria, precio, stock, stock_min),
            )
            return cur.fetchone()[0]

def producto_actualizar(id_producto, nombre, descripcion, id_categoria, precio, stock_min, activo) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_producto_actualizar(%s, %s, %s, %s, %s, %s, %s)",
                (id_producto, nombre, descripcion, id_categoria, precio, stock_min, activo),
            )
        conn.commit()

def producto_eliminar(id_producto: int) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_producto_eliminar(%s)", (id_producto,))
        conn.commit()

def producto_obtener(id_producto: int) -> Optional[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_producto_obtener(%s, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)",
                (id_producto,),
            )
            return cur.fetchone()

def producto_listar() -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_producto_listar('cur_productos')")
            cur.execute("FETCH ALL FROM cur_productos")
            filas = cur.fetchall()
        conn.commit()
        return filas

def crear_venta(id_cliente: int, lineas: list[tuple[int, int]]) -> tuple[int, str]:
    """
    Crea una factura completa con sus líneas de detalle, todo en
    una sola transacción (si algo falla -por ejemplo stock
    insuficiente- se revierte toda la venta).

    lineas: lista de tuplas (id_producto, cantidad)
    return: (id_factura, numero_factura)
    """
    with get_connection() as conn:
        try:
            with conn.cursor() as cur:
                cur.execute(
                    "CALL sp_factura_insertar(%s, NULL, NULL)", (id_cliente,)
                )
                id_factura, numero_factura = cur.fetchone()

                for id_producto, cantidad in lineas:
                    cur.execute(
                        "CALL sp_detalle_insertar(%s, %s, %s, NULL)",
                        (id_factura, id_producto, cantidad),
                    )
            conn.commit()
            return id_factura, numero_factura
        except Exception:
            conn.rollback()
            raise

def factura_obtener(id_factura: int) -> Optional[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_factura_obtener(%s, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)",
                (id_factura,),
            )
            return cur.fetchone()

def factura_listar() -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_factura_listar('cur_facturas')")
            cur.execute("FETCH ALL FROM cur_facturas")
            filas = cur.fetchall()
        conn.commit()
        return filas

def factura_anular(id_factura: int) -> None:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("CALL sp_factura_eliminar(%s)", (id_factura,))
        conn.commit()

def detalle_listar_por_factura(id_factura: int) -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "CALL sp_detalle_listar(%s, 'cur_detalle')", (id_factura,)
            )
            cur.execute("FETCH ALL FROM cur_detalle")
            filas = cur.fetchall()
        conn.commit()
        return filas

def stock_disponible(id_producto: int) -> int:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT fn_stock_disponible(%s)", (id_producto,))
            return cur.fetchone()[0]

def productos_bajo_stock_minimo() -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM fn_verificar_stock_minimo()")
            return cur.fetchall()

def valor_total_inventario() -> float:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT fn_valor_total_inventario()")
            return float(cur.fetchone()[0])

def total_ventas_por_cliente(id_cliente: int) -> float:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT fn_total_ventas_por_cliente(%s)", (id_cliente,))
            return float(cur.fetchone()[0])

def total_ventas_periodo(fecha_inicio: date, fecha_fin: date) -> float:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT fn_total_ventas_periodo(%s, %s)", (fecha_inicio, fecha_fin)
            )
            return float(cur.fetchone()[0])

def producto_mas_vendido() -> Optional[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM fn_producto_mas_vendido()")
            return cur.fetchone()

def reporte_inventario_valorizado() -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM vw_inventario_valorizado")
            return cur.fetchall()

def reporte_ventas_mensuales() -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM vw_ventas_mensuales")
            return cur.fetchall()

def reporte_top_10_productos() -> list[tuple]:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM vw_top_10_productos_vendidos")
            return cur.fetchall()

def _imprimir_tabla(filas, encabezados):
    print(" | ".join(encabezados))
    print("-" * 80)
    for fila in filas:
        print(" | ".join(str(v) for v in fila))

def main():
    print("=== TechStore CR - Demo Avance II ===\n")

    print("-- Categorías registradas --")
    _imprimir_tabla(
        categoria_listar(), ["id", "nombre", "descripcion", "activo", "fecha"]
    )

    print("\n-- Productos con stock bajo el mínimo --")
    _imprimir_tabla(
        productos_bajo_stock_minimo(), ["id", "nombre", "stock", "stock_min"]
    )

    print(f"\nValor total del inventario: ₡{valor_total_inventario():,.2f}")

    print("\n-- Registrando una venta nueva --")
    id_factura, numero = crear_venta(
        id_cliente=6,
        lineas=[(9, 1), (11, 2)], 
    )
    print(f"Factura creada: {numero} (id={id_factura})")

    print("\n-- Detalle de la factura recién creada --")
    _imprimir_tabla(
        detalle_listar_por_factura(id_factura),
        ["id_detalle", "id_factura", "producto", "cantidad", "precio", "subtotal"],
    )

    encabezado = factura_obtener(id_factura)
    print(f"\nEncabezado de factura: {encabezado}")

    print("\n-- Producto más vendido --")
    print(producto_mas_vendido())

    print("\n-- Top 10 productos vendidos (vista) --")
    _imprimir_tabla(
        reporte_top_10_productos(),
        ["id", "nombre", "codigo", "unidades", "total_generado"],
    )

if __name__ == "__main__":
    main()
