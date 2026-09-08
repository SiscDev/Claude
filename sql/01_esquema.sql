-- =====================================================================
-- 01_esquema.sql  -  Creacion de tablas
-- Oracle Database
--
-- Orden de creacion: primero las tablas padre (Alumnos, Asignaturas),
-- despues la tabla hija (Estudian), porque sus FK apuntan a ellas.
-- =====================================================================

-- Borrado previo (hija primero, por las FK). Ignora el error si no existen.
DROP TABLE Estudian      CASCADE CONSTRAINTS;
DROP TABLE Asignaturas   CASCADE CONSTRAINTS;
DROP TABLE Alumnos       CASCADE CONSTRAINTS;


CREATE TABLE Alumnos (
    DNI_Al       VARCHAR2(20),
    Nombre_Al    VARCHAR2(50)   NOT NULL,
    Apellidos_Al VARCHAR2(100)  NOT NULL,
    Fecha_Nac_Al DATE,
    Email_Al     VARCHAR2(100),

    CONSTRAINT pk_alumnos     PRIMARY KEY (DNI_Al),
    CONSTRAINT uq_alumnos_mail UNIQUE (Email_Al)
);


CREATE TABLE Asignaturas (
    Cod_As      VARCHAR2(20),
    Nombre_As   VARCHAR2(100) NOT NULL,
    Creditos_As NUMBER(3,1),
    Curso_As    NUMBER(1),

    CONSTRAINT pk_asignaturas PRIMARY KEY (Cod_As),
    CONSTRAINT ck_asig_creditos CHECK (Creditos_As > 0),
    CONSTRAINT ck_asig_curso    CHECK (Curso_As BETWEEN 1 AND 4)
);


CREATE TABLE Estudian (
    DNI_Al             VARCHAR2(20),
    Cod_As             VARCHAR2(20),
    Nota_Al_As         NUMBER(4,2),
    Convocatoria_Al_As NUMBER(2) DEFAULT 1,

    CONSTRAINT pk_estudian PRIMARY KEY (DNI_Al, Cod_As),

    CONSTRAINT ck_estudian_nota
        CHECK (Nota_Al_As BETWEEN 0 AND 10),

    CONSTRAINT ck_estudian_convocatoria
        CHECK (Convocatoria_Al_As >= 1),

    CONSTRAINT fk_estudian_alumno
        FOREIGN KEY (DNI_Al)
        REFERENCES Alumnos (DNI_Al)
        ON DELETE CASCADE,

    CONSTRAINT fk_estudian_asignatura
        FOREIGN KEY (Cod_As)
        REFERENCES Asignaturas (Cod_As)
        ON DELETE CASCADE
);
