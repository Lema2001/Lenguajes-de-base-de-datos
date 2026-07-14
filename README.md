# TechStore CR — Avance II (Base de Datos)

## Orden de ejecución

```
schema.sql               -- crea las 5 tablas
funciones.sql             -- crea las 15 funciones (algunas son usadas por los procedimientos)
procedimientos_crud.sql   -- crea los 25 procedimientos CRUD
vistas.sql                -- crea las 10 vistas
triggers.sql               -- crea los 5 triggers
datos_prueba.sql          -- puebla la base y genera ventas de ejemplo
```

Ejemplo con psql:
```bash
createdb techstore_cr
psql -d techstore_cr -f schema.sql
psql -d techstore_cr -f funciones.sql
psql -d techstore_cr -f procedimientos_crud.sql
psql -d techstore_cr -f vistas.sql
psql -d techstore_cr -f triggers.sql
psql -d techstore_cr -f datos_prueba.sql
```

Luego edita las credenciales en `DB_CONFIG` dentro de `07_app.py` y ejecuta:
```bash
pip install "psycopg[binary]"
python3 app.py
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
- **Sin CRUD directo desde Python**: `app.py` solo hace `CALL sp_...` para operaciones de escritura/lectura puntual, `SELECT * FROM fn_...()` para invocar funciones almacenadas, y `SELECT * FROM vw_...` para las vistas de reportería. Nunca hace `INSERT/UPDATE/DELETE/SELECT` directo sobre `Clientes`, `Productos`, `Facturas`, etc.

## Resumen de objetos entregados

| Tipo | Cantidad | Archivo |
|---|---|---|
| Tablas | 5 | `schema.sql` |
| Procedimientos CRUD | 25 (5 × tabla) | `procedimientos_crud.sql` |
| Funciones PL/pgSQL | 15 | `funciones.sql` |
| Vistas | 10 | `vistas.sql` |
| Triggers | 5 | `triggers.sql` |
| Datos de prueba | — | `datos_prueba.sql` |
| App Python (psycopg 3) | — | `app.py` |

