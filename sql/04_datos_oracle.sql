-- =====================================================================
-- 04_datos_oracle.sql  -  Poblado de las 4 tablas (Oracle)
--
-- Un INSERT por tabla, con la lista de columnas escrita UNA sola vez.
-- Oracle no admite VALUES de varias filas (eso es MySQL, alli daria
-- ORA-00933 "SQL command not properly ended"), asi que el equivalente
-- es SELECT ... FROM dual UNION ALL, una linea por fila.
--
-- REGLA DE ORO: se inserta SIEMPRE de padres a hijos.
--   1) PROFESORES   (padre de ASIGNATURAS.DNI_P)
--   2) ALUMNOS      (padre de ESTUDIAN.DNI_AL)
--   3) ASIGNATURAS  (hija de PROFESORES, padre de ESTUDIAN.COD_AS)
--   4) ESTUDIAN     (hija de ALUMNOS y de ASIGNATURAS)
--
-- Si insertas en ESTUDIAN un DNI_AL que no esta en ALUMNOS salta:
--   ORA-02291: integrity constraint (FK_ESTUDIAN_ALUMNO) violated
--   - parent key not found
--
-- Si las tablas no existen o quieres empezar de 0, ejecuta primero
-- 05_esquema_oracle.sql.
--
-- Contrapartida de este estilo compacto: al ser UN solo INSERT por
-- tabla, si una fila esta mal no entra ninguna de esa tabla. La version
-- con un INSERT por fila esta en el historial de git, por si prefieres
-- depurar fila a fila.
-- =====================================================================


-- ---------------------------------------------------------------------
-- DIAGNOSTICO PREVIO (si ya tenias datos cargados)
--
-- Que alumnos hay realmente. Los DNI del bloque 4) tienen que salir
-- aqui, exactamente igual escritos:
--     SELECT DNI_AL FROM ALUMNOS ORDER BY DNI_AL;
--
-- Si "a ojo" estan pero la FK sigue fallando, casi siempre son espacios
-- sobrantes. Los delimitadores los dejan a la vista:
--     SELECT '[' || DNI_AL || ']' AS DNI, LENGTH(DNI_AL) AS LARGO
--       FROM ALUMNOS ORDER BY DNI_AL;
-- Un '[12345678Z ]' de largo 10 no casa con '12345678Z' de largo 9.
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- LIMPIEZA (opcional) - DEJADA COMENTADA A PROPOSITO
-- Descomentala SOLO si quieres vaciar las tablas. Hijas primero.
-- ---------------------------------------------------------------------
-- DELETE FROM ESTUDIAN;
-- DELETE FROM ASIGNATURAS;
-- DELETE FROM ALUMNOS;
-- DELETE FROM PROFESORES;
-- COMMIT;


-- ---------------------------------------------------------------------
-- 1) PROFESORES
-- NCUENTA_P: 20 digitos (CCC espanol) en vez de un IBAN de 24, para que
-- entre tambien si la columna es VARCHAR2(20).
-- ---------------------------------------------------------------------
INSERT INTO PROFESORES (DNI_P, NOMBRE_P, APELLIDO1_P, APELLIDO2_P, NCUENTA_P, TELEFONO_P, ESPECIALIDAD_P, DIRECCION_P, CIUDAD_P)
SELECT '11111111A', 'Elena',  'Marin',   'Castro',   '21000418450200051332', '611223344', 'Bases de Datos',      'Calle Mayor 12',      'Madrid'    FROM dual UNION ALL
SELECT '22222222B', 'Javier', 'Ortega',  'Ibanez',   '21000418450200051333', '622334455', 'Programacion',        'Avda. del Puerto 45', 'Valencia'  FROM dual UNION ALL
SELECT '33333333C', 'Rocio',  'Herrera', 'Lozano',   '21000418450200051334', '633445566', 'Sistemas Operativos', 'Plaza Nueva 3',       'Sevilla'   FROM dual UNION ALL
SELECT '44444444D', 'Tomas',  'Bravo',   'Nieto',    '21000418450200051335', '644556677', 'Redes',               'Calle Girona 88',     'Barcelona' FROM dual UNION ALL
SELECT '55555555E', 'Nerea',  'Pardo',   'Quintana', '21000418450200051336', '655667788', 'Matematicas',         'Calle Uria 21',       'Oviedo'    FROM dual;


-- ---------------------------------------------------------------------
-- 2) ALUMNOS   <-- ESTE ES EL BLOQUE QUE EVITA EL ORA-02291
-- Si te lo saltas, ESTUDIAN no tiene padres a los que apuntar.
--
-- El CAST de la primera fila NO es decorativo: en un UNION ALL, Oracle
-- decide el tipo de cada columna por la PRIMERA rama. Un NULL pelado
-- ahi arriba frente al 'Da Silva' de abajo puede dar ORA-01790
-- (expression must have same datatype as corresponding expression).
-- Con el CAST queda fijado a VARCHAR2 y no hay duda.
-- ---------------------------------------------------------------------
INSERT INTO ALUMNOS (DNI_AL, NOMBRE_AL, APELLIDO1_AL, APELLIDO2_AL, EDAD_AL, TELEFONO_AL, DIRECCION_AL, CIUDAD_AL, APELLIDO3_AL)
SELECT '12345678Z', 'Lucia', 'Garcia',  'Fernandez', 22, '711111111', 'Calle Olmo 5',           'Madrid',    CAST(NULL AS VARCHAR2(50)) FROM dual UNION ALL
SELECT '23456789D', 'Marco', 'Ruiz',    'Perez',     23, '722222222', 'Calle Alcala 140',       'Madrid',    NULL                       FROM dual UNION ALL
SELECT '34567890V', 'Aitor', 'Sanchez', 'Molina',    21, '733333333', 'Avda. Blasco Ibanez 60', 'Valencia',  NULL                       FROM dual UNION ALL
SELECT '45678901G', 'Noa',   'Delgado', 'Ortiz',     22, '744444444', 'Calle Betis 10',         'Sevilla',   'Da Silva'                 FROM dual UNION ALL
SELECT '56789012B', 'Iker',  'Vidal',   'Romero',    24, '755555555', 'Carrer Mallorca 302',    'Barcelona', NULL                       FROM dual UNION ALL
SELECT '11223344B', 'Sara',  'Navarro', 'Gil',       20, '766666666', 'Calle Cervantes 7',      'Oviedo',    NULL                       FROM dual;


-- ---------------------------------------------------------------------
-- 3) ASIGNATURAS
-- DNI_P es FK a PROFESORES: cada DNI de aqui existe en el bloque 1).
-- Un profesor puede llevar varias asignaturas (Nerea lleva MAT01 y
-- EST01). Una asignatura solo tiene un profesor.
--
-- CREDITOS_AS con enteros: si la columna es NUMBER(1) o NUMBER sin
-- escala, un 4.5 se redondearia. Con NUMBER(3,1) puedes poner 4.5.
-- ---------------------------------------------------------------------
INSERT INTO ASIGNATURAS (COD_AS, NOMBRE_AS, CREDITOS_AS, FACULTAD_AS, DNI_P)
SELECT 'BD001', 'Bases de Datos',        6, 'Informatica', '11111111A' FROM dual UNION ALL
SELECT 'PRG01', 'Programacion',          6, 'Informatica', '22222222B' FROM dual UNION ALL
SELECT 'SOP01', 'Sistemas Operativos',   6, 'Informatica', '33333333C' FROM dual UNION ALL
SELECT 'RED01', 'Redes de Computadores', 6, 'Informatica', '44444444D' FROM dual UNION ALL
SELECT 'MAT01', 'Matematica Discreta',   4, 'Ciencias',    '55555555E' FROM dual UNION ALL
SELECT 'EST01', 'Estadistica',           4, 'Ciencias',    '55555555E' FROM dual;


-- ---------------------------------------------------------------------
-- 4) ESTUDIAN  (matriculas + notas)
-- Tabla puente. Cada DNI_AL sale del bloque 2) y cada COD_AS del 3).
-- Los decimales SIEMPRE con punto (7.35), nunca con coma.
--
-- Ojo con el 10 de Aitor: si NOTA_AL_AS es NUMBER(3,2) el maximo es
-- 9.99 y Oracle lo rechaza con ORA-01438 (value larger than specified
-- precision). Se arregla con:
--     ALTER TABLE ESTUDIAN MODIFY NOTA_AL_AS NUMBER(4,2);
--
-- La ultima fila va sin calificar, con la nota a NULL. Se queda al
-- final a proposito: el tipo de la columna lo fija la primera rama del
-- UNION ALL, que ahi arriba es un 8.75, asi que no necesita CAST.
-- ---------------------------------------------------------------------
INSERT INTO ESTUDIAN (DNI_AL, COD_AS, NOTA_AL_AS, CONVOCATORIA_AL_AS)
SELECT '12345678Z', 'BD001',  8.75, 1 FROM dual UNION ALL
SELECT '12345678Z', 'PRG01',  9.5,  1 FROM dual UNION ALL
SELECT '12345678Z', 'MAT01',  6.25, 2 FROM dual UNION ALL
SELECT '23456789D', 'BD001',  4.5,  1 FROM dual UNION ALL
SELECT '23456789D', 'PRG01',  7,    1 FROM dual UNION ALL
SELECT '23456789D', 'SOP01',  5,    2 FROM dual UNION ALL
SELECT '34567890V', 'BD001',  10,   1 FROM dual UNION ALL
SELECT '34567890V', 'RED01',  6.8,  1 FROM dual UNION ALL
SELECT '34567890V', 'EST01',  7.4,  1 FROM dual UNION ALL
SELECT '45678901G', 'MAT01',  0,    3 FROM dual UNION ALL
SELECT '45678901G', 'PRG01',  5.5,  2 FROM dual UNION ALL
SELECT '45678901G', 'SOP01',  8.2,  1 FROM dual UNION ALL
SELECT '56789012B', 'BD001',  7.35, 1 FROM dual UNION ALL
SELECT '56789012B', 'RED01',  9.1,  1 FROM dual UNION ALL
SELECT '11223344B', 'PRG01',  6,    1 FROM dual UNION ALL
SELECT '11223344B', 'EST01',  3.75, 1 FROM dual UNION ALL
SELECT '11223344B', 'BD001',  NULL, 1 FROM dual;


-- En Oracle, sin COMMIT los datos solo existen en tu sesion.
COMMIT;


-- ---------------------------------------------------------------------
-- COMPROBACION
-- ---------------------------------------------------------------------
SELECT 'PROFESORES' AS TABLA, COUNT(*) AS FILAS FROM PROFESORES
UNION ALL SELECT 'ALUMNOS', COUNT(*) FROM ALUMNOS
UNION ALL SELECT 'ASIGNATURAS', COUNT(*) FROM ASIGNATURAS
UNION ALL SELECT 'ESTUDIAN', COUNT(*) FROM ESTUDIAN;

-- Join de las 4 tablas. En Oracle se concatena con ||
SELECT a.APELLIDO1_AL || ' ' || a.APELLIDO2_AL || ', ' || a.NOMBRE_AL AS ALUMNO,
       s.NOMBRE_AS                                                    AS ASIGNATURA,
       s.FACULTAD_AS                                                  AS FACULTAD,
       p.NOMBRE_P || ' ' || p.APELLIDO1_P                             AS PROFESOR,
       e.NOTA_AL_AS                                                   AS NOTA,
       e.CONVOCATORIA_AL_AS                                           AS CONV
  FROM ESTUDIAN    e
  JOIN ALUMNOS     a ON a.DNI_AL = e.DNI_AL
  JOIN ASIGNATURAS s ON s.COD_AS = e.COD_AS
  JOIN PROFESORES  p ON p.DNI_P  = s.DNI_P
 ORDER BY ALUMNO, ASIGNATURA;
