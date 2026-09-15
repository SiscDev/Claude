-- =====================================================================
-- 05_esquema_oracle.sql  -  Reset y creacion del esquema REAL (Oracle)
--
-- Deja la base de datos desde 0 con las 4 tablas y sus columnas de
-- verdad: ALUMNOS, PROFESORES, ASIGNATURAS, ESTUDIAN.
--
-- OJO: el 01_esquema.sql crea OTRO esquema, mas reducido (Alumnos con
-- APELLIDOS_AL / FECHA_NAC_AL / EMAIL_AL y sin PROFESORES). Si lo
-- ejecutas y despues cargas 04_datos_oracle.sql te dara
-- ORA-00904: invalid identifier, porque APELLIDO1_AL no existiria.
-- Para empezar de 0 usa ESTE fichero y luego 04_datos_oracle.sql.
--
-- ORDEN DE USO:
--   1) 05_esquema_oracle.sql   (este: borra y crea)
--   2) 04_datos_oracle.sql     (mete los datos)
-- =====================================================================


-- ---------------------------------------------------------------------
-- PARTE 1: BORRADO
--
-- ATENCION: esto es IRREVERSIBLE. DROP TABLE es DDL, hace COMMIT
-- automatico, asi que no hay ROLLBACK que te salve.
--
--   CASCADE CONSTRAINTS  borra tambien las FK que apuntan a la tabla.
--                        Por eso el orden aqui da igual.
--   PURGE                se salta la papelera (recyclebin). Sin PURGE
--                        podrias recuperarla con
--                        FLASHBACK TABLE nombre TO BEFORE DROP;
--                        pero te ocupa cuota mientras siga ahi.
--
-- El bloque ignora el ORA-00942 (table or view does not exist), asi que
-- puedes ejecutarlo aunque falte alguna tabla o esten ya todas borradas.
-- ---------------------------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
    FOR t IN (SELECT nombre FROM (
                  SELECT 1 AS orden, 'ESTUDIAN'    AS nombre FROM dual
        UNION ALL SELECT 2,          'ASIGNATURAS'          FROM dual
        UNION ALL SELECT 3,          'ALUMNOS'              FROM dual
        UNION ALL SELECT 4,          'PROFESORES'           FROM dual
              ) ORDER BY orden)
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || t.nombre || ' CASCADE CONSTRAINTS PURGE';
            DBMS_OUTPUT.PUT_LINE('Borrada:    ' || t.nombre);
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN   -- -942 = la tabla no existe
                    RAISE;
                END IF;
                DBMS_OUTPUT.PUT_LINE('No existia: ' || t.nombre);
        END;
    END LOOP;
END;
/

-- Comprueba que no queda nada tuyo antes de seguir.
-- Deberia devolver 0 filas:
--     SELECT table_name FROM user_tables
--      WHERE table_name IN ('ALUMNOS','PROFESORES','ASIGNATURAS','ESTUDIAN');
--
-- Y la papelera vacia (si usaste PURGE, ya lo esta):
--     SELECT object_name, original_name FROM recyclebin;
--     PURGE RECYCLEBIN;


-- ---------------------------------------------------------------------
-- PARTE 2: CREACION
-- De padres a hijas: PROFESORES, ALUMNOS, ASIGNATURAS, ESTUDIAN.
-- ---------------------------------------------------------------------

-- Los telefonos y el numero de cuenta van como VARCHAR2, NUNCA como
-- NUMBER: un NUMBER se come el 0 inicial y no admite el prefijo +34.
-- NCUENTA_P con 24 para que entre tanto un CCC (20) como un IBAN (24).
CREATE TABLE PROFESORES (
    DNI_P          VARCHAR2(9),
    NOMBRE_P       VARCHAR2(50)  NOT NULL,
    APELLIDO1_P    VARCHAR2(50)  NOT NULL,
    APELLIDO2_P    VARCHAR2(50),
    NCUENTA_P      VARCHAR2(24),
    TELEFONO_P     VARCHAR2(15),
    ESPECIALIDAD_P VARCHAR2(50),
    DIRECCION_P    VARCHAR2(100),
    CIUDAD_P       VARCHAR2(50),

    CONSTRAINT PK_PROFESORES PRIMARY KEY (DNI_P)
);


-- APELLIDO3_AL admite NULL: es la columna anadida despues y casi nadie
-- tiene un tercer apellido.
CREATE TABLE ALUMNOS (
    DNI_AL       VARCHAR2(9),
    NOMBRE_AL    VARCHAR2(50)  NOT NULL,
    APELLIDO1_AL VARCHAR2(50)  NOT NULL,
    APELLIDO2_AL VARCHAR2(50),
    EDAD_AL      NUMBER(3),
    TELEFONO_AL  VARCHAR2(15),
    DIRECCION_AL VARCHAR2(100),
    CIUDAD_AL    VARCHAR2(50),
    APELLIDO3_AL VARCHAR2(50),

    CONSTRAINT PK_ALUMNOS  PRIMARY KEY (DNI_AL),
    CONSTRAINT CK_AL_EDAD  CHECK (EDAD_AL BETWEEN 16 AND 120)
);


-- CREDITOS_AS como NUMBER(3,1) para que quepan los 4.5 creditos.
-- Si fuera NUMBER(2) sin escala, un 4.5 se redondearia a 5 sin avisar.
CREATE TABLE ASIGNATURAS (
    COD_AS      VARCHAR2(10),
    NOMBRE_AS   VARCHAR2(100) NOT NULL,
    CREDITOS_AS NUMBER(3,1),
    FACULTAD_AS VARCHAR2(50),
    DNI_P       VARCHAR2(9),

    CONSTRAINT PK_ASIGNATURAS   PRIMARY KEY (COD_AS),
    CONSTRAINT CK_AS_CREDITOS   CHECK (CREDITOS_AS > 0),

    -- Una asignatura tiene un profesor. Un profesor, varias asignaturas.
    -- ON DELETE SET NULL: si borras al profesor, la asignatura se queda
    -- sin el en vez de desaparecer.
    CONSTRAINT FK_ASIGNATURA_PROFESOR
        FOREIGN KEY (DNI_P)
        REFERENCES PROFESORES (DNI_P)
        ON DELETE SET NULL
);


-- NOTA_AL_AS como NUMBER(4,2) y no NUMBER(3,2): con (3,2) el maximo
-- seria 9.99 y un 10 daria ORA-01438 (value larger than specified
-- precision).
CREATE TABLE ESTUDIAN (
    DNI_AL             VARCHAR2(9),
    COD_AS             VARCHAR2(10),
    NOTA_AL_AS         NUMBER(4,2),
    CONVOCATORIA_AL_AS NUMBER(2) DEFAULT 1,

    CONSTRAINT PK_ESTUDIAN PRIMARY KEY (DNI_AL, COD_AS),

    CONSTRAINT CK_ES_NOTA         CHECK (NOTA_AL_AS BETWEEN 0 AND 10),
    CONSTRAINT CK_ES_CONVOCATORIA CHECK (CONVOCATORIA_AL_AS BETWEEN 1 AND 6),

    -- Estas son las dos FK que te daban el ORA-02291 cuando ESTUDIAN
    -- apuntaba a un alumno que no existia.
    CONSTRAINT FK_ESTUDIAN_ALUMNO
        FOREIGN KEY (DNI_AL)
        REFERENCES ALUMNOS (DNI_AL)
        ON DELETE CASCADE,

    CONSTRAINT FK_ESTUDIAN_ASIGNATURA
        FOREIGN KEY (COD_AS)
        REFERENCES ASIGNATURAS (COD_AS)
        ON DELETE CASCADE
);


-- ---------------------------------------------------------------------
-- COMPROBACION
-- ---------------------------------------------------------------------
SELECT table_name FROM user_tables
 WHERE table_name IN ('ALUMNOS','PROFESORES','ASIGNATURAS','ESTUDIAN')
 ORDER BY table_name;

SELECT table_name, constraint_name, constraint_type
  FROM user_constraints
 WHERE table_name IN ('ALUMNOS','PROFESORES','ASIGNATURAS','ESTUDIAN')
 ORDER BY table_name, constraint_type, constraint_name;


-- ---------------------------------------------------------------------
-- ALTERNATIVA: vaciar los datos SIN borrar las tablas
--
-- Si lo que quieres es empezar de 0 con los datos pero conservar la
-- estructura, no hace falta dropear nada. Siempre de hijas a padres:
--     DELETE FROM ESTUDIAN;
--     DELETE FROM ASIGNATURAS;
--     DELETE FROM ALUMNOS;
--     DELETE FROM PROFESORES;
--     COMMIT;
--
-- Con DELETE y no con TRUNCATE: TRUNCATE sobre una tabla a la que
-- apunta una FK activa falla con ORA-02266 (unique/primary keys in
-- table referenced by enabled foreign keys), aunque la hija este vacia.
-- ---------------------------------------------------------------------
