-- ============================================================================
-- PROYECTO: Red Social Estudiantil Pascualina
-- ARCHIVO: 01_ddl_estructura_fisica.sql
-- DESCRIPCIÓN: Creación de tablas (DDL), llaves primarias/foráneas y datos de prueba
-- DBMS: PostgreSQL 17 / pgAdmin 4
-- AUTORES: Deimar Copete, Iván Mauricio Bolaños
-- ============================================================================

-- Limpieza previa si existen las tablas
DROP TABLE IF EXISTS asistencia_evento CASCADE;
DROP TABLE IF EXISTS evento CASCADE;
DROP TABLE IF EXISTS miembro_grupo CASCADE;
DROP TABLE IF EXISTS grupo CASCADE;
DROP TABLE IF EXISTS comentario CASCADE;
DROP TABLE IF EXISTS publicacion CASCADE;
DROP TABLE IF EXISTS seguidor CASCADE;
DROP TABLE IF EXISTS estudiante_habilidad CASCADE;
DROP TABLE IF EXISTS habilidad CASCADE;
DROP TABLE IF EXISTS estudiante CASCADE;
DROP TABLE IF EXISTS programa_academico CASCADE;

-- 1. Tabla Programa Académico
CREATE TABLE programa_academico (
    id_programa SERIAL PRIMARY KEY,
    nombre_programa VARCHAR(120) NOT NULL,
    facultad VARCHAR(100) NOT NULL
);

-- 2. Tabla Estudiante
CREATE TABLE estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    correo VARCHAR(120) UNIQUE NOT NULL,
    semestre INT NOT NULL CHECK (semestre >= 1 AND semestre <= 12),
    disponible_mentoria BOOLEAN DEFAULT FALSE,
    estado_academico VARCHAR(30) DEFAULT 'Activo',
    id_programa INT NOT NULL REFERENCES programa_academico(id_programa)
);

-- 3. Tabla Habilidad
CREATE TABLE habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre_habilidad VARCHAR(80) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

-- 4. Tabla Intermedia Estudiante - Habilidad
CREATE TABLE estudiante_habilidad (
    id_estudiante INT REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    id_habilidad INT REFERENCES habilidad(id_habilidad) ON DELETE CASCADE,
    nivel VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_estudiante, id_habilidad)
);

-- 5. Tabla Seguidores (Red de conexiones / Mentoría)
CREATE TABLE seguidor (
    id_seguidor INT REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    id_seguido INT REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    fecha_conexion DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_seguidor, id_seguido),
    CHECK (id_seguidor <> id_seguido)
);

-- 6. Tabla Publicación
CREATE TABLE publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    contenido TEXT NOT NULL,
    categoria VARCHAR(50) NOT NULL, -- 'Recurso Útil', 'Noticia Tech', 'Pregunta', 'Meme'
    num_reacciones INT DEFAULT 0,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 7. Tabla Comentario
CREATE TABLE comentario (
    id_comentario SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_publicacion INT NOT NULL REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 8. Tabla Grupo / Club de Interés
CREATE TABLE grupo (
    id_grupo SERIAL PRIMARY KEY,
    nombre_grupo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria VARCHAR(50) NOT NULL, -- 'Estudio', 'Hackatón', 'Programación Competitiva', 'Deportes'
    capacidad_maxima INT DEFAULT 30,
    id_creador INT NOT NULL REFERENCES estudiante(id_estudiante)
);

-- 9. Tabla Miembro Grupo
CREATE TABLE miembro_grupo (
    id_grupo INT REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    id_estudiante INT REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    rol VARCHAR(30) DEFAULT 'Miembro',
    estado VARCHAR(20) DEFAULT 'Activo',
    fecha_union DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_grupo, id_estudiante)
);

-- 10. Tabla Evento
CREATE TABLE evento (
    id_evento SERIAL PRIMARY KEY,
    titulo_evento VARCHAR(120) NOT NULL,
    tipo_evento VARCHAR(50) NOT NULL, -- 'Taller', 'Reunión Estudio', 'Social', 'Hackatón'
    fecha_evento DATE NOT NULL,
    lugar VARCHAR(100) NOT NULL,
    id_grupo INT REFERENCES grupo(id_grupo) ON DELETE SET NULL,
    id_organizador INT NOT NULL REFERENCES estudiante(id_estudiante)
);

-- 11. Tabla Asistencia Evento
CREATE TABLE asistencia_evento (
    id_evento INT REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_estudiante INT REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    estado_asistencia VARCHAR(30) DEFAULT 'Confirmado',
    PRIMARY KEY (id_evento, id_estudiante)
);

-- ============================================================================
-- INSERCIÓN DE DATOS DE PRUEBA (DML - INSERT)
-- ============================================================================

INSERT INTO programa_academico (nombre_programa, facultad) VALUES
('Ingeniería de Software', 'Ingeniería'),
('Ingeniería Eléctrica', 'Ingeniería'),
('Ingeniería Mecánica', 'Ingeniería'),
('Diseño Gráfico', 'Producción y Diseño');

INSERT INTO estudiante (nombre, apellido, correo, semestre, disponible_mentoria, estado_academico, id_programa) VALUES
('Deimar', 'Copete', 'deimar.copete@pascualbravo.edu.co', 8, TRUE, 'Activo', 1),
('Iván Mauricio', 'Bolaños', 'ivan.bolanos@pascualbravo.edu.co', 7, TRUE, 'Activo', 1),
('Mateo', 'Jaramillo', 'mateo.jaramillo@pascualbravo.edu.co', 4, FALSE, 'Activo', 1),
('Sofía', 'Morales', 'sofia.morales@pascualbravo.edu.co', 6, TRUE, 'Activo', 2),
('Camilo', 'Gómez', 'camilo.gomez@pascualbravo.edu.co', 2, FALSE, 'Activo', 3),
('Natalia', 'Ríos', 'natalia.rios@pascualbravo.edu.co', 9, TRUE, 'Activo', 4),
('Andrés', 'Pérez', 'andres.perez@pascualbravo.edu.co', 1, FALSE, 'Activo', 1);

INSERT INTO habilidad (nombre_habilidad, categoria) VALUES
('PostgreSQL y Modelado SQL', 'Bases de Datos'),
('Desarrollo Backend Python', 'Programación'),
('Algoritmos y Estructuras', 'Programación Competitiva'),
('Diseño UI/UX', 'Diseño');

INSERT INTO estudiante_habilidad VALUES
(1, 1, 'Avanzado'),
(1, 2, 'Avanzado'),
(2, 1, 'Avanzado'),
(2, 3, 'Intermedio'),
(4, 3, 'Avanzado'),
(6, 4, 'Avanzado');

INSERT INTO seguidor VALUES
(3, 1, CURRENT_DATE - 10),
(5, 1, CURRENT_DATE - 5),
(3, 2, CURRENT_DATE - 3),
(1, 2, CURRENT_DATE - 20);

INSERT INTO publicacion (titulo, contenido, categoria, num_reacciones, id_estudiante) VALUES
('Guía definitiva de Joins y Vistas en PostgreSQL 17', 'Comparto apuntes completos para el parcial de BD.', 'Recurso Útil', 28, 1),
('Convocatoria Maratón Interna de Programación', 'Inscripciones abiertas para equipos de 3 personas.', 'Noticia Tech', 35, 2),
('¿Cómo optimizar subconsultas con NOT EXISTS?', 'Tengo duda en el rendimiento frente a LEFT JOIN.', 'Pregunta', 12, 3),
('Cuando compila a la primera sin errores', 'Meme clásico de viernes por la noche.', 'Meme', 42, 2),
('Introducción a circuitos trifásicos', 'Material de apoyo semestre 5.', 'Recurso Útil', 16, 4);

INSERT INTO comentario (contenido, id_publicacion, id_estudiante) VALUES
('¡Excelente aporte, me salvó el taller!', 1, 3),
('Muy bien explicado el tema de vistas.', 1, 2),
('Ya armamos equipo para la maratón.', 2, 1),
('Usa EXPLAIN ANALYZE para comparar.', 3, 1);

INSERT INTO grupo (nombre_grupo, descripcion, categoria, capacidad_maxima, id_creador) VALUES
('Club Programación Competitiva Pascual', 'Entrenamiento semanal para maratones ICPC.', 'Programación Competitiva', 25, 1),
('Semillero Bases de Datos y Analítica', 'Proyectos aplicados en PostgreSQL y BI.', 'Estudio', 20, 2),
('Equipo Hackatón Medellín Tech', 'Desarrollo rápido de prototipos web.', 'Hackatón', 15, 1);

INSERT INTO miembro_grupo VALUES
(1, 1, 'Líder', 'Activo', CURRENT_DATE - 30),
(1, 2, 'Moderador', 'Activo', CURRENT_DATE - 25),
(1, 3, 'Miembro', 'Activo', CURRENT_DATE - 10),
(2, 2, 'Líder', 'Activo', CURRENT_DATE - 28),
(2, 1, 'Miembro', 'Activo', CURRENT_DATE - 20),
(2, 4, 'Miembro', 'Activo', CURRENT_DATE - 15),
(3, 1, 'Líder', 'Activo', CURRENT_DATE - 12);

INSERT INTO evento (titulo_evento, tipo_evento, fecha_evento, lugar, id_grupo, id_organizador) VALUES
('Taller Práctico: Vistas y Optimización SQL', 'Taller', CURRENT_DATE + 5, 'Bloque 5 - Sala Sistemas 3', 2, 2),
('Simulacro Maratón de Programación', 'Hackatón', CURRENT_DATE + 12, 'Auditorio Pascual Bravo', 1, 1),
('Grupo de Estudio: Cálculo Integral', 'Reunión Estudio', CURRENT_DATE + 2, 'Biblioteca Central', NULL, 4);

INSERT INTO asistencia_evento VALUES
(1, 1, 'Confirmado'),
(1, 2, 'Confirmado'),
(1, 3, 'Confirmado'),
(2, 1, 'Confirmado'),
(2, 2, 'Confirmado'),
(3, 4, 'Confirmado');
