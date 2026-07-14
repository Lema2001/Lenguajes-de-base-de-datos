# TechStore CR — Avance II (Base de Datos)

Proyecto: tienda tecnológica, PostgreSQL 16 + Python (psycopg 3).
Todo el código fue **probado de extremo a extremo** en una instancia real de PostgreSQL 16 (esquema, 25 procedimientos, 15 funciones, 10 vistas, 5 triggers, datos de prueba y el script Python), no es solo teoría.

## Orden de ejecución (importante)

```
01_schema.sql               -- crea las 5 tablas
03_funciones.sql             -- crea las 15 funciones (algunas son usadas por los procedimientos)
02_procedimientos_crud.sql   -- crea los 25 procedimientos CRUD
04_vistas.sql                -- crea las 10 vistas
05_triggers.sql               -- crea los 5 triggers
06_datos_prueba.sql          -- puebla la base y genera ventas de ejemplo
```

Ejemplo con psql:
```bash
createdb techstore_cr
psql -d techstore_cr -f 01_schema.sql
psql -d techstore_cr -f 03_funciones.sql
psql -d techstore_cr -f 02_procedimientos_crud.sql
psql -d techstore_cr -f 04_vistas.sql
psql -d techstore_cr -f 05_triggers.sql
psql -d techstore_cr -f 06_datos_prueba.sql
```

Luego edita las credenciales en `DB_CONFIG` dentro de `07_app.py` y ejecuta:
```bash
pip install "psycopg[binary]"
python3 07_app.py
```

## Modelo de datos

- **Categorias** → **Productos** (1:N)
- **Clientes** → **Facturas** (1:N)
- **Facturas** → **Detalle_Factura** ← **Productos** (Detalle_Factura resuelve la relación N:M entre Facturas y Productos)

## Decisiones de diseño clave

- **Baja lógica**: Clientes, Categorias y Productos nunca se borran físicamente vía procedimiento (`activo = FALSE`), para no perder el historial de ventas. Un trigger (`trg_prevenir_borrado_cliente`) además bloquea el `DELETE` físico de un cliente si ya tiene facturas.
- **Facturas**: "eliminar" = anular (`estado = 'ANULADA'`) y se borra su detalle, lo que dispara el trigger que repone el stock automáticamente.
- **Totales de factura**: nunca se calculan ni se escriben desde Python. El trigger `trg_recalcular_totales_factura` los recalcula siempre que cambia el detalle, usando las funciones `fn_calcular_subtotal_factura` / `fn_calcular_iva`.
- **IVA**: 13% (Costa Rica), centralizado en `fn_tasa_iva()` para que sea fácil de ajustar en un solo lugar.
- **Cursores**: 
  - Los 5 procedimientos `*_listar` abren un `REFCURSOR` con nombre; Python hace `FETCH ALL FROM <cursor>` dentro de la misma transacción (no hace `SELECT` directo sobre las tablas).
  - `fn_verificar_stock_minimo()` y `fn_producto_mas_vendido()` usan **cursores explícitos** (`CURSOR FOR ... OPEN ... FETCH ... LOOP ... CLOSE`) dentro de PL/pgSQL, como ejemplo adicional de manejo de cursores en funciones.
- **Sin CRUD directo desde Python**: `07_app.py` solo hace `CALL sp_...` para operaciones de escritura/lectura puntual, `SELECT * FROM fn_...()` para invocar funciones almacenadas, y `SELECT * FROM vw_...` para las vistas de reportería. Nunca hace `INSERT/UPDATE/DELETE/SELECT` directo sobre `Clientes`, `Productos`, `Facturas`, etc.

## Resumen de objetos entregados

| Tipo | Cantidad | Archivo |
|---|---|---|
| Tablas | 5 | `01_schema.sql` |
| Procedimientos CRUD | 25 (5 × tabla) | `02_procedimientos_crud.sql` |
| Funciones PL/pgSQL | 15 | `03_funciones.sql` |
| Vistas | 10 | `04_vistas.sql` |
| Triggers | 5 | `05_triggers.sql` |
| Datos de prueba | — | `06_datos_prueba.sql` |
| App Python (psycopg 3) | — | `07_app.py` |

## Notas para la presentación del avance

- Cada objeto SQL tiene un comentario justo arriba explicando su propósito.
- `06_datos_prueba.sql` genera 5 facturas usando los procedimientos almacenados (igual que lo haría la app), incluyendo una que se anula a propósito para demostrar la restauración de stock por trigger.
- Puedes verificar visualmente el efecto de los triggers con:
  ```sql
  SELECT numero_factura, subtotal, iva, total, estado FROM Facturas;
  SELECT id_producto, nombre, stock FROM Productos;
  SELECT * FROM vw_resumen_diario_ventas;
  ```
