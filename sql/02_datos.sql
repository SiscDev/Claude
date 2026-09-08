-- =====================================================================
-- 02_datos.sql  -  Poblado de las tablas
-- Oracle Database
--
-- REGLA DE ORO: se inserta SIEMPRE de padres a hijos.
--   1) Alumnos      (padre)
--   2) Asignaturas  (padre)
--   3) Estudian     (hija, con las dos FK)
-- Si lo haces al reves salta ORA-02291: integrity constraint violated
-- - parent key not found.
-- =====================================================================

-- Limpieza para poder re-ejecutar el script (hija primero).
DELETE FROM Estudian;
DELETE FROM Asignaturas;
DELETE FROM Alumnos;


-- ---------------------------------------------------------------------
-- 1) ALUMNOS
-- Las fechas usan el literal ANSI  DATE 'AAAA-MM-DD', que no depende
-- del formato de sesion (NLS_DATE_FORMAT).
-- ---------------------------------------------------------------------
INSERT INTO Alumnos VALUES ('12345678Z', 'Lucia', 'Garcia Fernandez', DATE '2003-04-12', 'lucia.garcia@example.com');
INSERT INTO Alumnos VALUES ('23456789D', 'Marco', 'Ruiz Perez',       DATE '2002-11-30', 'marco.ruiz@example.com');
INSERT INTO Alumnos VALUES ('34567890V', 'Aitor', 'Sanchez Molina',   DATE '2004-01-25', 'aitor.sanchez@example.com');
INSERT INTO Alumnos VALUES ('45678901G', 'Noa',   'Delgado Ortiz',    DATE '2003-07-08', 'noa.delgado@example.com');
INSERT INTO Alumnos VALUES ('56789012B', 'Iker',  'Vidal Romero',     DATE '2002-02-14', 'iker.vidal@example.com');
INSERT INTO Alumnos VALUES ('11223344B', 'Sara',  'Navarro Gil',      DATE '2004-09-03', 'sara.navarro@example.com');


-- ---------------------------------------------------------------------
-- 2) ASIGNATURAS
-- ---------------------------------------------------------------------
INSERT INTO Asignaturas VALUES ('BD001', 'Bases de Datos',        6,   2);
INSERT INTO Asignaturas VALUES ('PRG01', 'Programacion',          6,   1);
INSERT INTO Asignaturas VALUES ('SOP01', 'Sistemas Operativos',   6,   2);
INSERT INTO Asignaturas VALUES ('MAT01', 'Matematica Discreta',   4.5, 1);
INSERT INTO Asignaturas VALUES ('RED01', 'Redes de Computadores', 6,   3);


-- ---------------------------------------------------------------------
-- 3) ESTUDIAN  (matriculas + notas)
-- Aqui indico las columnas de forma explicita: es mas legible y no se
-- rompe si manana anades una columna a la tabla.
-- Los decimales se escriben SIEMPRE con punto (7.35), nunca con coma.
-- ---------------------------------------------------------------------
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('12345678Z', 'BD001',  8.75, 1);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('12345678Z', 'PRG01',  9.50, 1);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('12345678Z', 'MAT01',  6.25, 2);

INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('23456789D', 'BD001',  4.50, 1);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('23456789D', 'PRG01',  7.00, 1);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('23456789D', 'SOP01',  5.00, 2);

-- Un 10.00: esta fila es justo la que fallaba con DECIMAL(3,2) -> ORA-01438.
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('34567890V', 'BD001', 10.00, 1);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('34567890V', 'RED01',  6.80, 1);

INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('45678901G', 'MAT01',  0.00, 3);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('45678901G', 'PRG01',  5.50, 2);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('45678901G', 'SOP01',  8.20, 1);

INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('56789012B', 'BD001',  7.35, 1);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('56789012B', 'RED01',  9.10, 1);

INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('11223344B', 'PRG01',  6.00, 1);
INSERT INTO Estudian (DNI_Al, Cod_As, Nota_Al_As, Convocatoria_Al_As) VALUES ('11223344B', 'MAT01',  3.75, 1);

-- Matriculada pero todavia sin calificar: la nota va a NULL.
-- Como Convocatoria_Al_As tiene DEFAULT 1, se puede omitir.
INSERT INTO Estudian (DNI_Al, Cod_As) VALUES ('11223344B', 'BD001');


-- Sin COMMIT los datos solo existen en tu sesion.
COMMIT;


-- ---------------------------------------------------------------------
-- Comprobacion
-- ---------------------------------------------------------------------
SELECT a.Apellidos_Al || ', ' || a.Nombre_Al AS Alumno,
       s.Nombre_As                           AS Asignatura,
       e.Nota_Al_As                          AS Nota,
       e.Convocatoria_Al_As                  AS Conv
  FROM Estudian    e
  JOIN Alumnos     a ON a.DNI_Al = e.DNI_Al
  JOIN Asignaturas s ON s.Cod_As = e.Cod_As
 ORDER BY Alumno, Asignatura;
