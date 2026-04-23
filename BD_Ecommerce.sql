CREATE SCHEMA IF NOT EXISTS public;
SET search_path TO public;
-- =========================
-- LIMPIEZA
-- =========================
DROP MATERIALIZED VIEW IF EXISTS vista_productos_mas_vendidos;

DROP VIEW IF EXISTS vista_pedido_pago;
DROP VIEW IF EXISTS vista_detalle_pedido;
DROP VIEW IF EXISTS vista_pedidos_usuario;
DROP VIEW IF EXISTS vista_total_carrito;
DROP VIEW IF EXISTS vista_carrito;
DROP VIEW IF EXISTS vista_stock_disponible;
DROP VIEW IF EXISTS vista_stock_bajo;

DROP TABLE IF EXISTS DETALLE_PEDIDO CASCADE;
DROP TABLE IF EXISTS DETALLE_CARRITO CASCADE;
DROP TABLE IF EXISTS PAGO CASCADE;
DROP TABLE IF EXISTS PEDIDO CASCADE;
DROP TABLE IF EXISTS CARRITO CASCADE;
DROP TABLE IF EXISTS DETALLE_PRODUCTO CASCADE;
DROP TABLE IF EXISTS INVENTARIO CASCADE;
DROP TABLE IF EXISTS CATEGORIA CASCADE;
DROP TABLE IF EXISTS COLOR CASCADE;
DROP TABLE IF EXISTS TALLA CASCADE;
DROP TABLE IF EXISTS MODELO CASCADE;
DROP TABLE IF EXISTS USUARIO CASCADE;

-- =========================
-- TABLAS BASE
-- =========================

CREATE TABLE USUARIO (
    id_usuario SERIAL PRIMARY KEY,
    documento VARCHAR(11) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    contraseña TEXT NOT NULL,
    telefono VARCHAR(15),
    direccion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (length(documento) IN (8,11))
);

CREATE TABLE CATEGORIA (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE COLOR (
    id_color SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE TALLA (
    id_talla SERIAL PRIMARY KEY,
    nombre VARCHAR(10) NOT NULL
);

CREATE TABLE MODELO (
    id_modelo SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- =========================
-- PRODUCTOS
-- =========================

CREATE TABLE INVENTARIO (
    id_inven SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    marca VARCHAR(50),
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
);

CREATE TABLE DETALLE_PRODUCTO (
    id_detalle_pro SERIAL PRIMARY KEY,
    id_inven INT NOT NULL,
    id_color INT NOT NULL,
    id_talla INT NOT NULL,
    id_modelo INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    precio DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_inven) REFERENCES INVENTARIO(id_inven),
    FOREIGN KEY (id_color) REFERENCES COLOR(id_color),
    FOREIGN KEY (id_talla) REFERENCES TALLA(id_talla),
    FOREIGN KEY (id_modelo) REFERENCES MODELO(id_modelo),

    UNIQUE (id_inven, id_color, id_talla, id_modelo)
);

-- =========================
-- CARRITO
-- =========================

CREATE TABLE CARRITO (
    id_carrito SERIAL PRIMARY KEY,
    id_usuario INT UNIQUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
);

CREATE TABLE DETALLE_CARRITO (
    id_det_carrito SERIAL PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_detalle_pro INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),

    FOREIGN KEY (id_carrito) REFERENCES CARRITO(id_carrito) ON DELETE CASCADE,
    FOREIGN KEY (id_detalle_pro) REFERENCES DETALLE_PRODUCTO(id_detalle_pro),

    UNIQUE (id_carrito, id_detalle_pro)
);

-- =========================
-- PEDIDOS
-- =========================

CREATE TABLE PEDIDO (
    id_pedido SERIAL PRIMARY KEY,
    id_usuario INT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'pendiente',
    total DECIMAL(10,2) DEFAULT 0,

    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
);

CREATE TABLE DETALLE_PEDIDO (
    id_det_pedido SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_detalle_pro INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_detalle_pro) REFERENCES DETALLE_PRODUCTO(id_detalle_pro)
);

-- =========================
-- PAGOS
-- =========================

CREATE TABLE PAGO (
    id_pago SERIAL PRIMARY KEY,
    id_pedido INT UNIQUE,
    metodo VARCHAR(50),
    estado VARCHAR(20) DEFAULT 'pendiente',
    fecha_pago TIMESTAMP,

    FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido)
);

-- =========================
-- VISTAS
-- =========================

CREATE OR REPLACE VIEW vista_carrito AS
SELECT 
    ca.id_carrito,
    u.id_usuario,
    u.documento,
    u.nombre AS usuario,
    dc.id_det_carrito,
    i.nombre AS producto,
    c.nombre AS color,
    t.nombre AS talla,
    m.nombre AS modelo,
    dp.precio,
    dc.cantidad,
    (dp.precio * dc.cantidad) AS subtotal
FROM CARRITO ca
JOIN USUARIO u ON ca.id_usuario = u.id_usuario
JOIN DETALLE_CARRITO dc ON ca.id_carrito = dc.id_carrito
JOIN DETALLE_PRODUCTO dp ON dc.id_detalle_pro = dp.id_detalle_pro
JOIN INVENTARIO i ON dp.id_inven = i.id_inven
JOIN COLOR c ON dp.id_color = c.id_color
JOIN TALLA t ON dp.id_talla = t.id_talla
JOIN MODELO m ON dp.id_modelo = m.id_modelo;

CREATE OR REPLACE VIEW vista_total_carrito AS
SELECT 
    id_carrito,
    id_usuario,
    SUM(subtotal) AS total
FROM vista_carrito
GROUP BY id_carrito, id_usuario;

CREATE OR REPLACE VIEW vista_pedidos_usuario AS
SELECT 
    p.id_pedido,
    p.id_usuario,
    u.documento,
    p.fecha,
    p.estado,
    p.total
FROM PEDIDO p
JOIN USUARIO u ON p.id_usuario = u.id_usuario;

CREATE OR REPLACE VIEW vista_detalle_pedido AS
SELECT 
    p.id_pedido,
    p.id_usuario,
    u.documento,
    i.nombre AS producto,
    c.nombre AS color,
    t.nombre AS talla,
    m.nombre AS modelo,
    dped.cantidad,
    dped.precio_unitario,
    (dped.cantidad * dped.precio_unitario) AS subtotal
FROM PEDIDO p
JOIN USUARIO u ON p.id_usuario = u.id_usuario
JOIN DETALLE_PEDIDO dped ON p.id_pedido = dped.id_pedido
JOIN DETALLE_PRODUCTO dp ON dped.id_detalle_pro = dp.id_detalle_pro
JOIN INVENTARIO i ON dp.id_inven = i.id_inven
JOIN COLOR c ON dp.id_color = c.id_color
JOIN TALLA t ON dp.id_talla = t.id_talla
JOIN MODELO m ON dp.id_modelo = m.id_modelo;

CREATE OR REPLACE VIEW vista_pedido_pago AS
SELECT 
    p.id_pedido,
    p.id_usuario,
    u.documento,
    p.total,
    p.estado AS estado_pedido,
    pa.metodo,
    pa.estado AS estado_pago,
    pa.fecha_pago
FROM PEDIDO p
JOIN USUARIO u ON p.id_usuario = u.id_usuario
LEFT JOIN PAGO pa ON p.id_pedido = pa.id_pedido;

CREATE OR REPLACE VIEW vista_stock_disponible AS
SELECT 
    dp.id_detalle_pro,
    i.nombre AS producto,
    c.nombre AS color,
    t.nombre AS talla,
    m.nombre AS modelo,
    dp.stock,
    dp.precio
FROM DETALLE_PRODUCTO dp
JOIN INVENTARIO i ON dp.id_inven = i.id_inven
JOIN COLOR c ON dp.id_color = c.id_color
JOIN TALLA t ON dp.id_talla = t.id_talla
JOIN MODELO m ON dp.id_modelo = m.id_modelo
WHERE dp.stock > 0;

CREATE OR REPLACE VIEW vista_stock_bajo AS
SELECT 
    i.nombre AS producto,
    dp.stock
FROM DETALLE_PRODUCTO dp
JOIN INVENTARIO i ON dp.id_inven = i.id_inven
WHERE dp.stock < 5;

-- =========================
-- MATERIALIZED VIEW
-- =========================

CREATE MATERIALIZED VIEW vista_productos_mas_vendidos AS
SELECT 
    i.id_inven,
    i.nombre AS producto,
    SUM(dped.cantidad) AS total_vendido
FROM DETALLE_PEDIDO dped
JOIN DETALLE_PRODUCTO dp ON dped.id_detalle_pro = dp.id_detalle_pro
JOIN INVENTARIO i ON dp.id_inven = i.id_inven
GROUP BY i.id_inven, i.nombre
ORDER BY total_vendido DESC;

-- =========================
-- TRIGGERS STOCK
-- =========================

CREATE OR REPLACE FUNCTION fn_control_stock()
RETURNS TRIGGER AS $$
DECLARE
    stock_actual INT;
BEGIN
    SELECT stock INTO stock_actual
    FROM DETALLE_PRODUCTO
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    IF stock_actual < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %, solicitado: %',
        stock_actual, NEW.cantidad;
    END IF;

    UPDATE DETALLE_PRODUCTO
    SET stock = stock - NEW.cantidad
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_control_stock
BEFORE INSERT ON DETALLE_PEDIDO
FOR EACH ROW
EXECUTE FUNCTION fn_control_stock();

-- Restore stock
CREATE OR REPLACE FUNCTION fn_restore_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE DETALLE_PRODUCTO
    SET stock = stock + OLD.cantidad
    WHERE id_detalle_pro = OLD.id_detalle_pro;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_restore_stock
AFTER DELETE ON DETALLE_PEDIDO
FOR EACH ROW
EXECUTE FUNCTION fn_restore_stock();

-- Update stock
CREATE OR REPLACE FUNCTION fn_update_stock()
RETURNS TRIGGER AS $$
DECLARE
    diferencia INT;
    stock_actual INT;
BEGIN
    diferencia := NEW.cantidad - OLD.cantidad;

    SELECT stock INTO stock_actual
    FROM DETALLE_PRODUCTO
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    IF diferencia > 0 AND stock_actual < diferencia THEN
        RAISE EXCEPTION 'Stock insuficiente para actualizar';
    END IF;

    UPDATE DETALLE_PRODUCTO
    SET stock = stock - diferencia
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock
BEFORE UPDATE ON DETALLE_PEDIDO
FOR EACH ROW
EXECUTE FUNCTION fn_update_stock();

-- =========================
-- ÍNDICES
-- =========================

CREATE INDEX idx_usuario_correo ON USUARIO(correo);
CREATE INDEX idx_inventario_categoria ON INVENTARIO(id_categoria);
CREATE INDEX idx_detalle_producto_inven ON DETALLE_PRODUCTO(id_inven);
CREATE INDEX idx_carrito_usuario ON CARRITO(id_usuario);
CREATE INDEX idx_pedido_usuario ON PEDIDO(id_usuario);


-- ==========================================
-- 1. TABLAS BASE (Sin dependencias)
-- ==========================================

INSERT INTO CATEGORIA (nombre) VALUES 
('Masculino'), 
('Femenino');

INSERT INTO COLOR (nombre) VALUES 
('Rojo'), ('Verde'), ('Amarillo'), ('Azul'), ('Anaranjado'), 
('Rosa'), ('Negro'), ('Blanco'), ('Gris'), ('Violeta');

INSERT INTO TALLA (nombre) VALUES 
('S'), ('M'), ('L'), ('XL');

INSERT INTO MODELO (nombre) VALUES 
('Camisa'), ('Blusa'), ('Pantalon');

INSERT INTO USUARIO (documento, nombre, correo, contraseña, telefono, direccion) VALUES
('71231567', 'Renato Solis', 'rena@email.com', 'rena123', '987654321', 'Av. Sistemas 123'),
('10567891', 'Ariana Sotillo ', 'aria@email.com', 'ari123', '912345678', 'Calle Lima 456'),
('72357678', 'Maria Garcia', 'maria@email.com', 'maria123', '923456789', 'Jr. Arequipa 789'),
('73446789', 'Sebastián Casavilca', 'sebas@email.com', 'sebas123', '934567890', 'Av. Larco 101'),
('74573890', 'Yummy Lucero', 'yummy@email.com', 'yum123', '945678901', 'Calle Cusco 202'),
('10784256', 'Luis Torres', 'luis@email.com', 'luis123', '956789012', 'Av. Tacna 303'),
('75674801', 'Elena Paz', 'elena@email.com', 'elena123', '967890123', 'Jr. Trujillo 404'),
('76789412', 'Diego Meza', 'diego@email.com', 'diego123', '978901234', 'Av. Brasil 505'),
('78901323', 'Sofia Vega', 'sofia@email.com', 'sofia123', '989012345', 'Calle Ica 606'),
('78901334', 'Jorge Luna', 'jorge@email.com', 'jorge123', '990123456', 'Av. Puno 707');

-- ==========================================
-- 2. PRODUCTOS (Dependen de las tablas base)
-- ==========================================

INSERT INTO INVENTARIO (nombre, descripcion, marca, id_categoria) VALUES 
('Camisa Hoodie Urban', 'Polera con capucha y bolsillo canguro', 'UrbanStyle', 1), -- id 1
('Jean Clasico', 'Denim resistente azul oscuro', 'Levis', 2),                      -- id 2
('Pantalón Jogger Fit', 'Pantalón deportivo con ajuste en tobillos', 'Nike', 2),   -- id 3
('Camisa Formal', 'Algodón pima extra suave', 'ModaIng', 1),                       -- id 4
('Pantalón Ejecutivo', 'Saco y pantalón de lana fina', 'Pierre Cardin', 2),           -- id 5
('Blusa con Estampado', 'Algodón 100% con diseño infantil', 'BabyStyle', 1),            -- id 6
('Jeans con Elástico', 'Denim suave para mayor movilidad', 'BabyStyle', 2);        -- id 7

-- Creamos variaciones (Detalles) con stock para que los triggers permitan comprar
INSERT INTO DETALLE_PRODUCTO (id_inven, id_color, id_talla, id_modelo, stock, precio) VALUES
(4, 2, 2, 1, 25, 95.00),  -- Camisa Formal, Verde, M, Camisa, 25 unidades a 95.00
(5, 7, 3, 3, 40, 45.50),  -- Pantalón Ejecutivo, Negro, L, Pantalón, 40 unidades a 45.50
(6, 1, 2, 2, 15, 299.00), -- Blusa con Estampado, Rojo, M, Blusa, 15 unidades a 299.00
(1, 1, 1, 1, 10, 85.00);  -- Camisa Urban, Rojo, S, Camisa, 10 unidades a 85.00

-- ==========================================
-- 3. CARRITO DE COMPRAS
-- ==========================================

-- Creamos carritos para los usuarios 1 y 2
INSERT INTO CARRITO (id_usuario) VALUES 
(1), 
(2);

-- Agregamos productos a esos carritos
INSERT INTO DETALLE_CARRITO (id_carrito, id_detalle_pro, cantidad) VALUES
(1, 1, 2), -- El usuario 1 tiene 2 Camisas Formales en su carrito
(1, 4, 1), -- El usuario 1 tiene 1 Camisa Urban en su carrito
(2, 3, 1); -- El usuario 2 tiene 1 Blusa con Estampado

-- ==========================================
-- 4. PEDIDOS (Se ejecutan los Triggers de Stock aquí)
-- ==========================================

-- Simulamos pedidos para los usuarios 3 y 4
INSERT INTO PEDIDO (id_usuario, estado, total) VALUES
(3, 'pendiente', 91.00),   -- Total se puede actualizar luego, ponemos un estimado basado en sus detalles
(4, 'completado', 299.00);

-- Al insertar el detalle, el Trigger 'trg_control_stock' restará la cantidad del DETALLE_PRODUCTO
INSERT INTO DETALLE_PEDIDO (id_pedido, id_detalle_pro, cantidad, precio_unitario) VALUES
(1, 2, 2, 45.50),  -- Pedido 1 lleva 2 Pantalones Ejecutivos a 45.50 (2 * 45.50 = 91.00)
(2, 3, 1, 299.00); -- Pedido 2 lleva 1 Blusa Estampada a 299.00

-- ==========================================
-- 5. PAGOS
-- ==========================================

-- Registramos los pagos correspondientes a los pedidos
INSERT INTO PAGO (id_pedido, metodo, estado, fecha_pago) VALUES
(1, 'Yape', 'pendiente', NULL), 
(2, 'Tarjeta de Crédito', 'aprobado', CURRENT_TIMESTAMP);