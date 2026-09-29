# Informe de Práctica 1. Conceptos fundamentales de PostgreSQL
**Autor:** Adrián David Hernández González

---

## 1. Creación de la base de datos

Crear una base de datos llamada `biblioteca`.

```sql
CREATE DATABASE biblioteca;
\c biblioteca
```

---

## 2. Creación de usuarios

**Objetivos:**
* Crear `admin_biblio` con permisos de administrador.
* Crear `usuario_biblio` con permisos de lectura.
* Crear el rol `lectores`, asignar permisos y añadir al `usuario_biblio`.
* Consultar usuarios, cambiar contraseña y asegurar la restricción de borrado.

```sql
-- Crear los usuarios
CREATE ROLE admin_biblio WITH LOGIN SUPERUSER PASSWORD 'xxxx';
CREATE ROLE usuario_biblio WITH LOGIN PASSWORD 'xxxx';

-- Crear el rol de lectores y asignar permisos de solo lectura
CREATE ROLE lectores;
GRANT CONNECT ON DATABASE biblioteca TO lectores;
GRANT USAGE ON SCHEMA public TO lectores;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;

-- Asignar el rol al usuario
GRANT lectores TO usuario_biblio;

-- Cambiar la contraseña de usuario_biblio
ALTER ROLE usuario_biblio WITH PASSWORD 'xxxx';

-- Asegurar que el usuario no pueda eliminar registros
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM lectores;
```

**Consultar las tablas del sistema para listar todos los usuarios creados (`pg_roles`):**
```sql
SELECT rolname, rolsuper, rolcanlogin FROM pg_roles WHERE rolname IN ('admin_biblio', 'usuario_biblio', 'lectores');
```

```text
    rolname     | rolsuper | rolcanlogin 
----------------+----------+-------------
 lectores       | f        | f
 usuario_biblio | f        | t
 admin_biblio   | t        | t
(3 rows)
```

---

## 3. Creación de tablas

Crear las tablas con sus respectivas claves primarias y foráneas, habilitando el borrado en cascada para la posterior prueba de eliminación.

```sql
CREATE TABLE autores (
    id_autor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

CREATE TABLE libros (
    id_libro SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    año_publicacion INT,
    id_autor INT,
    CONSTRAINT fk_autor FOREIGN KEY (id_autor) REFERENCES autores(id_autor) ON DELETE CASCADE
);

CREATE TABLE prestamos (
    id_prestamo SERIAL PRIMARY KEY,
    id_libro INT,
    fecha_prestamo DATE,
    fecha_devolucion DATE,
    usuario_prestatario VARCHAR(100),
    CONSTRAINT fk_libro FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE
    CONSTRAINT chk_fecha_devolucion_valida CHECK (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_prestamo)
);
```

---

## 4. Inserción de datos

Insertar al menos 5 autores, 8 libros y 5 préstamos de ejemplo.

```sql
INSERT INTO autores (id_autor, nombre, nacionalidad) VALUES
(1, 'Gabriel García Márquez', 'Colombiana'),
(2, 'Jane Austen', 'Británica'),
(3, 'Jorge Luis Borges', 'Argentina'),
(4, 'Isabel Allende', 'Chilena'),
(5, 'George Orwell', 'Británica');

INSERT INTO libros (id_libro, titulo, año_publicacion, id_autor) VALUES
(1, 'Cien años de soledad', 1967, 1),
(2, 'El amor en los tiempos del cólera', 1985, 1),
(3, 'Orgullo y prejuicio', 1813, 2),
(4, 'Sentido y sensibilidad', 1811, 2),
(5, 'Ficciones', 1944, 3),
(6, 'El Aleph', 1949, 3),
(7, 'La casa de los espíritus', 1982, 4),
(8, '1984', 1949, 5);

INSERT INTO prestamos (id_prestamo, id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES
(1, 1, '2026-08-01', '2026-08-15', 'Carlos Mendoza'),
(2, 3, '2026-08-10', '2026-08-24', 'Lucía Fernández'),
(3, 5, '2026-09-15', NULL, 'Sofía Ramírez'),
(4, 8, '2026-09-29', NULL, 'Marcos Delgado'),
(5, 7, '2026-09-29', NULL, 'Elena Morales');
```

---

## 5. Consultas básicas

**1. Listar todos los libros con su autor correspondiente:**
```sql
SELECT l.id_libro, l.titulo, l.año_publicacion, a.nombre AS autor
FROM libros l 
JOIN autores a ON l.id_autor = a.id_autor;
```
```text
 id_libro |               titulo              | año_publicacion |         autor         
----------+-----------------------------------+-----------------+------------------------
        1 | Cien años de soledad              |            1967 | Gabriel García Márquez
        2 | El amor en los tiempos del cólera |            1985 | Gabriel García Márquez
        3 | Orgullo y prejuicio               |            1813 | Jane Austen
        4 | Sentido y sensibilidad            |            1811 | Jane Austen
        5 | Ficciones                         |            1944 | Jorge Luis Borges
        6 | El Aleph                          |            1949 | Jorge Luis Borges
        7 | La casa de los espíritus          |            1982 | Isabel Allende
        8 | 1984                              |            1949 | George Orwell
```

**2. Mostrar los préstamos que aún no tienen fecha de devolución:**
```sql
SELECT * FROM prestamos WHERE fecha_devolucion IS NULL;
```
```text
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           3 |        5 | 2026-09-15     |                  | Sofía Ramírez
           4 |        8 | 2026-09-29     |                  | Marcos Delgado
           5 |        7 | 2026-09-29     |                  | Elena Morales
```

**3. Obtener los autores que tienen más de un libro registrado:**
```sql
SELECT a.nombre, COUNT(l.id_libro) 
FROM autores a 
JOIN libros l ON a.id_autor = l.id_autor 
GROUP BY a.nombre 
HAVING COUNT(l.id_libro) > 1;
```
```text
         nombre         | count 
------------------------+-------
 Jorge Luis Borges      |     2
 Jane Austen            |     2
 Gabriel García Márquez |     2
```

---

## 6. Consultas con agregación

**1. Calcular el número total de préstamos realizados:**
*(El listado general de todos los préstamos para su comprobación)*
```sql
SELECT COUNT(*) AS total_prestamos FROM prestamos;
SELECT * FROM prestamos;
```
```text
 total_prestamos 
-----------------
               5

 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           1 |        1 | 2026-08-01     | 2026-08-15       | Carlos Mendoza
           2 |        3 | 2026-08-10     | 2026-08-24       | Lucía Fernández
           3 |        5 | 2026-09-15     |                  | Sofía Ramírez
           4 |        8 | 2026-09-29     |                  | Marcos Delgado
           5 |        7 | 2026-09-29     |                  | Elena Morales
```

**2. Obtener el número de libros prestados por cada usuario:**
```sql
SELECT p.usuario_prestatario, COUNT(p.usuario_prestatario) AS total_prestamos
FROM prestamos p
GROUP BY p.usuario_prestatario;
```
```text
 usuario_prestatario | total_prestamos 
---------------------+-----------------
 Lucía Fernández     |               1
 Sofía Ramírez       |               1
 Carlos Mendoza      |               1
 Marcos Delgado      |               1
 Elena Morales       |               1
```

---

## 7. Modificación de datos

**1. Actualizar la fecha de devolución de un préstamo pendiente:**
```sql
UPDATE prestamos
SET fecha_devolucion = '2027-01-01'
WHERE id_prestamo = 3;

-- Comprobación:
SELECT * FROM prestamos;
```
```text
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           1 |        1 | 2026-08-01     | 2026-08-15       | Carlos Mendoza
           2 |        3 | 2026-08-10     | 2026-08-24       | Lucía Fernández
           4 |        8 | 2026-09-29     |                  | Marcos Delgado
           5 |        7 | 2026-09-29     |                  | Elena Morales
           3 |        5 | 2026-09-15     | 2027-01-01       | Sofía Ramírez
```

**2. Eliminar un libro y comprobar el efecto en la tabla de préstamos (Cascada):**
Al crear la tabla con `ON DELETE CASCADE`, si borramos el libro con ID 8, el préstamo asociado (ID 4) se elimina automáticamente.
```sql
DELETE FROM libros WHERE id_libro = 8;

-- Comprobación en la tabla préstamos (el préstamo 4 desaparece):
SELECT * FROM prestamos;
```
```text
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           1 |        1 | 2026-08-01     | 2026-08-15       | Carlos Mendoza
           2 |        3 | 2026-08-10     | 2026-08-24       | Lucía Fernández
           5 |        7 | 2026-09-29     |                  | Elena Morales
           3 |        5 | 2026-09-15     | 2027-01-01       | Sofía Ramírez
```

---

## 8. Creación de vistas

**1. Crear la vista `vista_libros_prestados`:**
```sql
CREATE VIEW vista_libros_prestados AS
SELECT l.titulo AS titulo, a.nombre AS autor, p.usuario_prestatario AS prestatario
FROM libros l 
JOIN autores a ON l.id_autor = a.id_autor
JOIN prestamos p ON l.id_libro = p.id_libro;

SELECT * FROM vista_libros_prestados;
```
```text
          titulo          |         autor          |   prestatario   
--------------------------+------------------------+-----------------
 Cien años de soledad     | Gabriel García Márquez | Carlos Mendoza
 Orgullo y prejuicio      | Jane Austen            | Lucía Fernández
 La casa de los espíritus | Isabel Allende         | Elena Morales
 Ficciones                | Jorge Luis Borges      | Sofía Ramírez
```

**2. Conceder permisos de consulta sobre esta vista únicamente a `usuario_biblio`:**
```sql
REVOKE ALL ON vista_libros_prestados FROM PUBLIC;
GRANT SELECT ON vista_libros_prestados TO usuario_biblio;
```

---

## 9. Funciones y consultas avanzadas

**1. Crear una función que reciba el nombre de un autor y devuelva sus libros:**
```sql
CREATE OR REPLACE FUNCTION libros_de_autor(p_autor VARCHAR)
RETURNS TABLE(id_libro INT, titulo VARCHAR, año_publicacion INT) AS $$
    SELECT l.id_libro, l.titulo, l.año_publicacion
    FROM libros l
    JOIN autores a ON l.id_autor = a.id_autor
    WHERE a.nombre ILIKE '%' || p_autor || '%';
$$ LANGUAGE sql;

-- Ejecución:
SELECT * FROM libros_de_autor('Jane Austen');
```
```text
 id_libro |         titulo         | año_publicacion 
----------+------------------------+-----------------
        3 | Orgullo y prejuicio    |            1813
        4 | Sentido y sensibilidad |            1811
```

**2. Consulta que devuelve los tres libros más prestados:**
```sql
SELECT l.id_libro AS id, l.titulo AS titulo, COUNT(p.id_libro) AS veces_prestado
FROM libros l 
JOIN prestamos p ON l.id_libro = p.id_libro
GROUP BY l.id_libro
ORDER BY COUNT(p.id_libro) DESC
LIMIT 3;
```
```text
 id |          titulo          | veces_prestado 
----+--------------------------+----------------
  5 | Ficciones                |              1
  7 | La casa de los espíritus |              1
  1 | Cien años de soledad     |              1
```

---

## 10. Exportación e importación de datos

**1. Exportar el contenido de la tabla `libros` a un archivo CSV:**
```sql
\copy libros TO '/home/usuario/ADBD/libros_exportados.csv' WITH (FORMAT CSV, HEADER, ENCODING 'UTF8');
```

**2. Importar datos adicionales de autores desde un archivo CSV externo:**
```sql
\copy autores (nombre, nacionalidad) FROM '/home/usuario/ADBD/nuevos_autores.csv' WITH (FORMAT CSV, HEADER, ENCODING 'UTF8');

-- Comprobación:
SELECT * FROM autores;
```
```text
 id_autor |         nombre         | nacionalidad 
----------+------------------------+--------------
        1 | Gabriel García Márquez | Colombiana
        2 | Jane Austen            | Británica
        3 | Jorge Luis Borges      | Argentina
        4 | Isabel Allende         | Chilena
        5 | George Orwell          | Británica
        6 | Julio Cortázar         | Argentina
        7 | Virginia Woolf         | Británica
        8 | Mario Vargas Llosa     | Peruana
```