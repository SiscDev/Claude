-- =====================================================================
-- 03_datos_mysql.sql  -  Poblado de las tablas (MySQL / freeSQL)
--
-- Este script es para el esquema REAL de freeSQL, con 4 tablas:
--   ALUMNOS, PROFESORES, ASIGNATURAS, ESTUDIAN
-- (el 02_datos.sql es la version Oracle, con un esquema mas reducido
--  y sin PROFESORES, no sirve aqui).
--
-- REGLA DE ORO: se inserta SIEMPRE de padres a hijos.
--   1) PROFESORES   (padre de ASIGNATURAS.DNI_P)
--   2) ALUMNOS      (padre de ESTUDIAN.DNI_AL)
--   3) ASIGNATURAS  (hija de PROFESORES, padre de ESTUDIAN.COD_AS)
--   4) ESTUDIAN     (hija de ALUMNOS y de ASIGNATURAS)
-- Si lo haces al reves salta el error 1452:
--   Cannot add or update a child row: a foreign key constraint fails.
--
-- Sin acentos ni enyes a proposito: asi el script entra igual aunque la
-- conexion venga en latin1 en vez de utf8mb4.
-- =====================================================================

-- En freeSQL tu base de datos se llama algo como sql12345678.
-- Descomenta y pon la tuya si tu cliente no la selecciona ya:
-- USE sql12345678;


-- ---------------------------------------------------------------------
-- LIMPIEZA (opcional) - DEJADA COMENTADA A PROPOSITO
--
-- Descomentala SOLO si quieres vaciar las tablas para re-ejecutar el
-- script. Si ya tenias datos tuyos cargados, esto los borra.
-- Siempre de hijas a padres.
-- ---------------------------------------------------------------------
-- DELETE FROM ESTUDIAN;
-- DELETE FROM ASIGNATURAS;
-- DELETE FROM ALUMNOS;
-- DELETE FROM PROFESORES;


-- ---------------------------------------------------------------------
-- 1) PROFESORES
-- NCUENTA_P: 20 digitos (CCC espanol) en vez de un IBAN de 24, para que
-- entre tambien si la columna es VARCHAR(20).
-- ---------------------------------------------------------------------
INSERT INTO PROFESORES
    (DNI_P, NOMBRE_P, APELLIDO1_P, APELLIDO2_P, NCUENTA_P, TELEFONO_P, ESPECIALIDAD_P, DIRECCION_P, CIUDAD_P)
VALUES
    ('11111111A', 'Elena',  'Marin',   'Castro',   '21000418450200051332', '611223344', 'Bases de Datos',      'Calle Mayor 12',      'Madrid'),
    ('22222222B', 'Javier', 'Ortega',  'Ibanez',   '21000418450200051333', '622334455', 'Programacion',        'Avda. del Puerto 45', 'Valencia'),
    ('33333333C', 'Rocio',  'Herrera', 'Lozano',   '21000418450200051334', '633445566', 'Sistemas Operativos', 'Plaza Nueva 3',       'Sevilla'),
    ('44444444D', 'Tomas',  'Bravo',   'Nieto',    '21000418450200051335', '644556677', 'Redes',               'Calle Girona 88',     'Barcelona'),
    ('55555555E', 'Nerea',  'Pardo',   'Quintana', '21000418450200051336', '655667788', 'Matematicas',         'Calle Uria 21',       'Oviedo');


-- ---------------------------------------------------------------------
-- 2) ALUMNOS
-- Si YA tienes alumnos cargados, saltate este bloque, pero entonces
-- cambia los DNI del bloque 4) por los tuyos. Para verlos:
--     SELECT DNI_AL FROM ALUMNOS;
--
-- APELLIDO3_AL admite NULL (columna anadida despues): solo Noa lo tiene.
-- ---------------------------------------------------------------------
INSERT INTO ALUMNOS
    (DNI_AL, NOMBRE_AL, APELLIDO1_AL, APELLIDO2_AL, EDAD_AL, TELEFONO_AL, DIRECCION_AL, CIUDAD_AL, APELLIDO3_AL)
VALUES
    ('12345678Z', 'Lucia', 'Garcia',  'Fernandez', 22, '711111111', 'Calle Olmo 5',           'Madrid',    NULL),
    ('23456789D', 'Marco', 'Ruiz',    'Perez',     23, '722222222', 'Calle Alcala 140',       'Madrid',    NULL),
    ('34567890V', 'Aitor', 'Sanchez', 'Molina',    21, '733333333', 'Avda. Blasco Ibanez 60', 'Valencia',  NULL),
    ('45678901G', 'Noa',   'Delgado', 'Ortiz',     22, '744444444', 'Calle Betis 10',         'Sevilla',   'Da Silva'),
    ('56789012B', 'Iker',  'Vidal',   'Romero',    24, '755555555', 'Carrer Mallorca 302',    'Barcelona', NULL),
    ('11223344B', 'Sara',  'Navarro', 'Gil',       20, '766666666', 'Calle Cervantes 7',      'Oviedo',    NULL);


-- ---------------------------------------------------------------------
-- 3) ASIGNATURAS
-- DNI_P es FK a PROFESORES: cada codigo de aqui tiene que existir en el
-- bloque 1). Un profesor puede llevar varias asignaturas (Nerea lleva
-- MAT01 y EST01). Una asignatura solo tiene un profesor.
--
-- CREDITOS_AS con valores enteros: si la columna es INT, un 4.5 se
-- redondearia sin avisarte. Si la tienes como DECIMAL, puedes usar 4.5.
-- ---------------------------------------------------------------------
INSERT INTO ASIGNATURAS
    (COD_AS, NOMBRE_AS, CREDITOS_AS, FACULTAD_AS, DNI_P)
VALUES
    ('BD001', 'Bases de Datos',        6, 'Informatica', '11111111A'),
    ('PRG01', 'Programacion',          6, 'Informatica', '22222222B'),
    ('SOP01', 'Sistemas Operativos',   6, 'Informatica', '33333333C'),
    ('RED01', 'Redes de Computadores', 6, 'Informatica', '44444444D'),
    ('MAT01', 'Matematica Discreta',   4, 'Ciencias',    '55555555E'),
    ('EST01', 'Estadistica',           4, 'Ciencias',    '55555555E');


-- ---------------------------------------------------------------------
-- 4) ESTUDIAN  (matriculas + notas)
-- Tabla puente: DNI_AL sale de ALUMNOS y COD_AS de ASIGNATURAS.
-- Los decimales se escriben SIEMPRE con punto (7.35), nunca con coma.
-- ---------------------------------------------------------------------
INSERT INTO ESTUDIAN
    (DNI_AL, COD_AS, NOTA_AL_AS, CONVOCATORIA_AL_AS)
VALUES
    ('12345678Z', 'BD001',  8.75, 1),
    ('12345678Z', 'PRG01',  9.50, 1),
    ('12345678Z', 'MAT01',  6.25, 2),

    ('23456789D', 'BD001',  4.50, 1),
    ('23456789D', 'PRG01',  7.00, 1),
    ('23456789D', 'SOP01',  5.00, 2),

    -- Ojo con este 10.00: si NOTA_AL_AS es DECIMAL(3,2) el maximo es
    -- 9.99 y MySQL lo rechaza ("Out of range value"). Se arregla con:
    --     ALTER TABLE ESTUDIAN MODIFY NOTA_AL_AS DECIMAL(4,2);
    ('34567890V', 'BD001', 10.00, 1),
    ('34567890V', 'RED01',  6.80, 1),
    ('34567890V', 'EST01',  7.40, 1),

    ('45678901G', 'MAT01',  0.00, 3),
    ('45678901G', 'PRG01',  5.50, 2),
    ('45678901G', 'SOP01',  8.20, 1),

    ('56789012B', 'BD001',  7.35, 1),
    ('56789012B', 'RED01',  9.10, 1),

    ('11223344B', 'PRG01',  6.00, 1),
    ('11223344B', 'EST01',  3.75, 1);

-- Matriculada pero todavia sin calificar: la nota va a NULL.
INSERT INTO ESTUDIAN (DNI_AL, COD_AS, NOTA_AL_AS, CONVOCATORIA_AL_AS)
VALUES ('11223344B', 'BD001', NULL, 1);

-- En MySQL no hace falta COMMIT: la sesion va en autocommit.


-- ---------------------------------------------------------------------
-- COMPROBACION
-- ---------------------------------------------------------------------
SELECT 'PROFESORES' AS Tabla, COUNT(*) AS Filas FROM PROFESORES
UNION ALL SELECT 'ALUMNOS',     COUNT(*) FROM ALUMNOS
UNION ALL SELECT 'ASIGNATURAS', COUNT(*) FROM ASIGNATURAS
UNION ALL SELECT 'ESTUDIAN',    COUNT(*) FROM ESTUDIAN;

-- Join de las 4 tablas. En MySQL se concatena con CONCAT(), no con ||.
SELECT CONCAT(a.APELLIDO1_AL, ' ', a.APELLIDO2_AL, ', ', a.NOMBRE_AL) AS Alumno,
       s.NOMBRE_AS                                                    AS Asignatura,
       s.FACULTAD_AS                                                  AS Facultad,
       CONCAT(p.NOMBRE_P, ' ', p.APELLIDO1_P)                         AS Profesor,
       e.NOTA_AL_AS                                                   AS Nota,
       e.CONVOCATORIA_AL_AS                                           AS Conv
  FROM ESTUDIAN    e
  JOIN ALUMNOS     a ON a.DNI_AL = e.DNI_AL
  JOIN ASIGNATURAS s ON s.COD_AS = e.COD_AS
  JOIN PROFESORES  p ON p.DNI_P  = s.DNI_P
 ORDER BY Alumno, Asignatura;
