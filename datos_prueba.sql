INSERT INTO Categorias (nombre, descripcion) VALUES
 ('Laptops',        'Computadoras portátiles'),
 ('Periféricos',    'Mouse, teclados, audífonos, webcams'),
 ('Monitores',      'Pantallas para computadora'),
 ('Almacenamiento', 'Discos duros, SSD, USB'),
 ('Componentes',    'Partes internas: RAM, tarjetas, fuentes');


INSERT INTO Clientes (cedula, nombre, apellidos, email, telefono, direccion) VALUES
 ('101110111', 'Ana',      'Rodríguez Solano',  'ana.rodriguez@mail.com',   '8888-1111', 'San José, Costa Rica'),
 ('202220222', 'Carlos',   'Jiménez Vargas',    'carlos.jimenez@mail.com', '8888-2222', 'Heredia, Costa Rica'),
 ('303330333', 'María',    'Fernández Castro',  'maria.fernandez@mail.com','8888-3333', 'Alajuela, Costa Rica'),
 ('404440444', 'Luis',     'Mora Chacón',       'luis.mora@mail.com',      '8888-4444', 'Cartago, Costa Rica'),
 ('505550555', 'Sofía',    'Araya Méndez',      'sofia.araya@mail.com',    '8888-5555', 'San Rafael, San José'),
 ('606660666', 'Diego',    'Vega Ramírez',      'diego.vega@mail.com',     '8888-6666', 'Puntarenas, Costa Rica'),
 ('707770777', 'Valeria',  'Salas Rojas',       'valeria.salas@mail.com',  '8888-7777', 'Liberia, Guanacaste'),
 ('808880888', 'Andrés',   'Campos Guzmán',     'andres.campos@mail.com',  '8888-8888', 'Limón, Costa Rica');

INSERT INTO Productos (codigo, nombre, descripcion, id_categoria, precio_unitario, stock, stock_minimo) VALUES
 ('LAP-001', 'Laptop Lenovo ThinkPad E14',   'Core i5, 16GB RAM, 512GB SSD', 1, 650000, 12, 3),
 ('LAP-002', 'Laptop HP Pavilion 15',        'Core i7, 16GB RAM, 1TB SSD',   1, 720000,  8, 3),
 ('LAP-003', 'Laptop ASUS VivoBook',         'Core i3, 8GB RAM, 256GB SSD',  1, 420000, 15, 4),
 ('PER-001', 'Mouse Logitech M170',          'Mouse inalámbrico',            2,  12000, 40, 10),
 ('PER-002', 'Teclado Mecánico Redragon',    'Teclado gamer RGB',            2,  35000, 25, 8),
 ('PER-003', 'Audífonos HyperX Cloud',       'Audífonos con micrófono',      2,  45000, 20, 6),
 ('PER-004', 'Webcam Logitech C920',         'Webcam Full HD',               2,  55000, 10, 5),
 ('MON-001', 'Monitor Samsung 24"',          'Monitor Full HD 24 pulgadas',  3, 145000, 14, 4),
 ('MON-002', 'Monitor LG UltraWide 29"',     'Monitor ultrawide IPS',        3, 265000,  6, 2),
 ('ALM-001', 'SSD Kingston 480GB',           'Disco de estado sólido SATA',  4,  38000, 30, 8),
 ('ALM-002', 'Disco Duro Externo 1TB',       'Disco duro portátil USB 3.0',  4,  45000, 18, 5),
 ('ALM-003', 'USB SanDisk 64GB',             'Memoria USB 3.0',              4,   9000, 60, 15),
 ('COM-001', 'Memoria RAM Kingston 8GB',     'RAM DDR4 3200MHz',             5,  28000, 22, 6),
 ('COM-002', 'Fuente de Poder EVGA 600W',    'Fuente certificada 80+ Bronze',5,  55000,  9, 3),
 ('COM-003', 'Tarjeta Madre ASUS B450',      'Tarjeta madre AM4',            5,  95000,  7, 2);


DO $$
DECLARE
    v_id_factura INT;
    v_numero     VARCHAR;
    v_id_detalle INT;
BEGIN
    CALL sp_factura_insertar(1, v_id_factura, v_numero);
    CALL sp_detalle_insertar(v_id_factura, 1, 1, v_id_detalle);  
    CALL sp_detalle_insertar(v_id_factura, 4, 2, v_id_detalle);  
END $$;

DO $$
DECLARE
    v_id_factura INT;
    v_numero     VARCHAR;
    v_id_detalle INT;
BEGIN
    CALL sp_factura_insertar(2, v_id_factura, v_numero);
    CALL sp_detalle_insertar(v_id_factura, 8, 1, v_id_detalle);  
    CALL sp_detalle_insertar(v_id_factura, 5, 1, v_id_detalle);  
    CALL sp_detalle_insertar(v_id_factura, 6, 1, v_id_detalle);  
END $$;

DO $$
DECLARE
    v_id_factura INT;
    v_numero     VARCHAR;
    v_id_detalle INT;
BEGIN
    CALL sp_factura_insertar(3, v_id_factura, v_numero);
    CALL sp_detalle_insertar(v_id_factura, 10, 3, v_id_detalle); 
    CALL sp_detalle_insertar(v_id_factura, 12, 5, v_id_detalle); 
END $$;

DO $$
DECLARE
    v_id_factura INT;
    v_numero     VARCHAR;
    v_id_detalle INT;
BEGIN
    CALL sp_factura_insertar(4, v_id_factura, v_numero);
    CALL sp_detalle_insertar(v_id_factura, 2, 1, v_id_detalle);  
END $$;

DO $$
DECLARE
    v_id_factura INT;
    v_numero     VARCHAR;
    v_id_detalle INT;
BEGIN
    CALL sp_factura_insertar(5, v_id_factura, v_numero);
    CALL sp_detalle_insertar(v_id_factura, 13, 4, v_id_detalle); 
    CALL sp_factura_eliminar(v_id_factura);                      
END $$;