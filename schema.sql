DROP TABLE IF EXISTS Detalle_Factura CASCADE;
DROP TABLE IF EXISTS Facturas        CASCADE;
DROP TABLE IF EXISTS Productos       CASCADE;
DROP TABLE IF EXISTS Clientes        CASCADE;
DROP TABLE IF EXISTS Categorias      CASCADE;

CREATE TABLE Categorias (
    id_categoria    SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(255),
    activo          BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE Clientes (
    id_cliente      SERIAL PRIMARY KEY,
    cedula          VARCHAR(20)  NOT NULL UNIQUE,
    nombre          VARCHAR(80)  NOT NULL,
    apellidos       VARCHAR(100) NOT NULL,
    email           VARCHAR(120) NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    direccion       VARCHAR(255),
    fecha_registro  TIMESTAMP NOT NULL DEFAULT NOW(),
    activo          BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE Productos (
    id_producto      SERIAL PRIMARY KEY,
    codigo           VARCHAR(30)  NOT NULL UNIQUE,
    nombre           VARCHAR(120) NOT NULL,
    descripcion      VARCHAR(255),
    id_categoria     INT NOT NULL REFERENCES Categorias(id_categoria),
    precio_unitario  NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    stock            INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo     INT NOT NULL DEFAULT 5 CHECK (stock_minimo >= 0),
    activo           BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE Facturas (
    id_factura      SERIAL PRIMARY KEY,
    numero_factura  VARCHAR(20) NOT NULL UNIQUE,
    id_cliente      INT NOT NULL REFERENCES Clientes(id_cliente),
    fecha_factura   TIMESTAMP NOT NULL DEFAULT NOW(),
    subtotal        NUMERIC(12,2) NOT NULL DEFAULT 0,
    iva             NUMERIC(12,2) NOT NULL DEFAULT 0,
    total           NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado          VARCHAR(20) NOT NULL DEFAULT 'ACTIVA'
                     CHECK (estado IN ('ACTIVA','ANULADA'))
);

CREATE TABLE Detalle_Factura (
    id_detalle       SERIAL PRIMARY KEY,
    id_factura       INT NOT NULL REFERENCES Facturas(id_factura) ON DELETE CASCADE,
    id_producto      INT NOT NULL REFERENCES Productos(id_producto),
    cantidad         INT NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal         NUMERIC(12,2) NOT NULL
);

CREATE INDEX idx_productos_categoria   ON Productos(id_categoria);
CREATE INDEX idx_productos_activo      ON Productos(activo);
CREATE INDEX idx_facturas_cliente      ON Facturas(id_cliente);
CREATE INDEX idx_facturas_fecha        ON Facturas(fecha_factura);
CREATE INDEX idx_detalle_factura       ON Detalle_Factura(id_factura);
CREATE INDEX idx_detalle_producto      ON Detalle_Factura(id_producto);
CREATE INDEX idx_clientes_activo       ON Clientes(activo);
