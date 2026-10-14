BEGIN;


CREATE TABLE vivero(
  id_vivero SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  longitud NUMERIC(9,6),
  latitud NUMERIC(8,6)
);

CREATE TABLE zona(
  id_zona SERIAL PRIMARY KEY,
  nombre_zona VARCHAR(50) NOT NULL,
  longitud NUMERIC(9,6),
  latitud NUMERIC(8,6),
  id_vivero INT NOT NULL,

  CONSTRAINT fk_vivero FOREIGN KEY (id_vivero) 
  REFERENCES vivero(id_vivero) ON DELETE CASCADE
);

CREATE TABLE producto(
  id_producto SERIAL PRIMARY KEY,
  nombre_producto VARCHAR(100) NOT NULL,
  categoria VARCHAR(50) NOT NULL,
  precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0)
);

CREATE TABLE stock_zona_producto(
  id_zona INT,
  id_producto INT,
  cantidad INT NOT NULL DEFAULT 0 CHECK (cantidad >= 0),

  PRIMARY KEY (id_zona, id_producto),

  CONSTRAINT fk_zona FOREIGN KEY (id_zona)
  REFERENCES zona(id_zona) ON DELETE CASCADE,

  CONSTRAINT fk_producto FOREIGN KEY (id_producto)
  REFERENCES producto(id_producto) ON DELETE CASCADE
);

CREATE TABLE empleado(
  id_empleado SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono INT NOT NULL
);

CREATE TABLE asignacion_empleado_zona (
    id_asignacion SERIAL PRIMARY KEY,
    id_zona INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    puesto VARCHAR(100) NOT NULL,

    CONSTRAINT fk_zona_asignacion
        FOREIGN KEY (id_zona)
        REFERENCES zona(id_zona),

    CONSTRAINT fk_empleado_asignacion
        FOREIGN KEY (id_empleado)
        REFERENCES empleado(id_empleado),

    CONSTRAINT uq_asignacion
        UNIQUE (id_empleado, id_zona, fecha_inicio),

    CONSTRAINT chk_fechas_asignacion
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);


CREATE TABLE cliente(
  id_cliente SERIAL PRIMARY KEY,
  nombre_cliente VARCHAR(100),
  fecha_ingreso DATE,
  volumen_mensual INT
);

CREATE TABLE pedido(
  id_pedido SERIAL PRIMARY KEY,
  fecha_compra DATE NOT NULL,
  importe_total NUMERIC(10,2) NOT NULL CHECK (importe_total > 0),
  id_empleado INT NOT NULL,
  id_cliente INT NOT NULL,

  CONSTRAINT fk_empleado FOREIGN KEY (id_empleado)
  REFERENCES empleado(id_empleado),

  CONSTRAINT fk_cliente FOREIGN KEY (id_cliente)
  REFERENCES cliente(id_cliente)
);

CREATE TABLE detalle_pedido(
  id_producto INT,
  id_pedido INT,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),

  PRIMARY KEY(id_producto, id_pedido),

  CONSTRAINT fk_producto FOREIGN KEY (id_producto)
  REFERENCES producto(id_producto),

  CONSTRAINT fk_pedido FOREIGN KEY (id_pedido)
  REFERENCES pedido(id_pedido)
);

CREATE TABLE bonificacion (
    id_bonificacion SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    volumen_minimo NUMERIC(12,2) NOT NULL,
    importe_bonificacion NUMERIC(10,2) NOT NULL
);

CREATE TABLE cliente_bonificacion (
    id_cliente INT,
    id_bonificacion INT,
    anio INT,
    mes INT CHECK (mes BETWEEN 1 AND 12),

    PRIMARY KEY (id_cliente, anio, mes),

    CONSTRAINT fk_cliente_bonificacion
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),

    CONSTRAINT fk_bonificacion_cliente
        FOREIGN KEY (id_bonificacion)
        REFERENCES bonificacion(id_bonificacion)
);

-- 1. VIVEROS
INSERT INTO vivero (id_vivero, nombre, longitud, latitud) VALUES
(1, 'Vivero Norte', -16.300100, 28.480100),
(2, 'Vivero Sur', -16.250200, 28.420200),
(3, 'Vivero Este', -16.200300, 28.450300),
(4, 'Vivero Oeste', -16.350400, 28.460400),
(5, 'Vivero Central', -16.280500, 28.440500);

-- 2. ZONAS
INSERT INTO zona (id_zona, nombre_zona, longitud, latitud, id_vivero) VALUES
(1, 'Zona de sombra', -16.300110, 28.480110, 1),
(2, 'Zona de exterior', -16.300120, 28.480120, 1),
(3, 'Zona de invernadero', -16.250210, 28.420210, 2),
(4, 'Zona de aromáticas', -16.200310, 28.450310, 3),
(5, 'Zona de árboles', -16.350410, 28.460410, 4);

-- 3. PRODUCTOS
INSERT INTO producto (id_producto, nombre_producto, categoria, precio) VALUES
(1, 'Monstera deliciosa', 'Planta de interior', 18.50),
(2, 'Lavanda', 'Aromática', 6.75),
(3, 'Olivo joven', 'Árbol', 24.00),
(4, 'Geranio', 'Planta de exterior', 4.50),
(5, 'Sustrato universal', 'Sustrato', 8.25);

-- 4. STOCK POR ZONA Y PRODUCTO
INSERT INTO stock_zona_producto (id_zona, id_producto, cantidad) VALUES
(1, 1, 35),
(1, 5, 80),
(2, 4, 120),
(3, 1, 20),
(4, 2, 65),
(5, 3, 18);

-- 5. EMPLEADOS
INSERT INTO empleado (id_empleado, nombre, telefono) VALUES
(1, 'Lucía Pérez', 600123001),
(2, 'Marcos Díaz', 600123002),
(3, 'Sara González', 600123003),
(4, 'Daniel Rodríguez', 600123004),
(5, 'Elena Martín', 600123005);

-- 6. ASIGNACIONES DE EMPLEADOS A ZONAS
INSERT INTO asignacion_empleado_zona
    (id_asignacion, id_zona, id_empleado, fecha_inicio, fecha_fin, puesto) VALUES
(1, 1, 1, '2025-01-10', '2025-06-30', 'Encargada de zona'),
(2, 2, 1, '2025-07-01', '2025-12-31', 'Responsable de exterior'),
(3, 3, 2, '2025-02-01', '2025-08-31', 'Operario de invernadero'),
(4, 4, 3, '2025-03-01', NULL, 'Especialista en aromáticas'),
(5, 5, 4, '2025-04-01', '2025-10-31', 'Encargado de árboles');

-- 7. CLIENTES
INSERT INTO cliente (id_cliente, nombre_cliente, fecha_ingreso, volumen_mensual) VALUES
(1, 'Jardines Atlántico', '2024-01-15', 850),
(2, 'Floristería La Palma', '2024-03-10', 420),
(3, 'Hotel Mirador', '2025-02-01', 1250),
(4, 'Comunidad Los Cedros', '2025-05-20', 300),
(5, 'Paisajismo Verde', '2025-07-01', 1750);

-- 8. PEDIDOS
INSERT INTO pedido
    (id_pedido, fecha_compra, importe_total, id_empleado, id_cliente) VALUES
(1, '2026-09-02', 55.50, 1, 1),
(2, '2026-09-05', 40.50, 2, 2),
(3, '2026-09-08', 96.00, 3, 3),
(4, '2026-09-12', 33.00, 4, 4),
(5, '2026-09-15', 82.50, 5, 5);

-- 9. DETALLES DE PEDIDO
INSERT INTO detalle_pedido
    (id_producto, id_pedido, cantidad, precio_unitario) VALUES
(1, 1, 3, 18.50),
(4, 2, 9, 4.50),
(3, 3, 4, 24.00),
(5, 4, 4, 8.25),
(2, 5, 10, 6.75),
(4, 5, 3, 4.50);

-- 10. DEFINICIÓN DE BONIFICACIONES
INSERT INTO bonificacion
    (id_bonificacion, nombre, volumen_minimo, importe_bonificacion) VALUES
(1, 'Bronce', 100.00, 5.00),
(2, 'Plata', 300.00, 15.00),
(3, 'Oro', 500.00, 30.00),
(4, 'Platino', 1000.00, 60.00),
(5, 'Diamante', 1500.00, 100.00);

-- 11. BONIFICACIÓN ASIGNADA A CLIENTES POR MES
INSERT INTO cliente_bonificacion (id_cliente, id_bonificacion, anio, mes) VALUES
(1, 3, 2026, 9),
(2, 2, 2026, 9),
(3, 4, 2026, 9),
(4, 1, 2026, 9),
(5, 5, 2026, 9);


COMMIT;


