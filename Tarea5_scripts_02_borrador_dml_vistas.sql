-- ============================================================================
-- PROYECTO: Red Social Estudiantil Pascualina
-- ARCHIVO: 02_borrador_dml_vistas.sql
-- DESCRIPCIÓN: Borrador inicial de consultas DML y vistas propuestas por el equipo
-- ============================================================================

-- Borrador Consulta 1: Estudiantes mentores
SELECT e.nombre, e.apellido, p.nombre_programa, h.nombre_habilidad
FROM estudiante e
JOIN programa_academico p ON e.id_programa = p.id_programa
JOIN estudiante_habilidad eh ON e.id_estudiante = eh.id_estudiante
JOIN habilidad h ON eh.id_habilidad = h.id_habilidad
WHERE e.semestre >= 6 AND e.disponible_mentoria = TRUE;

-- Borrador Consulta 2: Publicaciones destacadas
SELECT pub.titulo, pub.categoria, pub.num_reacciones, COUNT(c.id_comentario) AS comentarios
FROM publicacion pub
LEFT JOIN comentario c ON pub.id_publicacion = c.id_publicacion
GROUP BY pub.id_publicacion, pub.titulo, pub.categoria, pub.num_reacciones
HAVING pub.num_reacciones > 15;

-- Borrador Consulta 3: Ocupación de grupos
SELECT g.nombre_grupo, g.categoria, COUNT(mg.id_estudiante) AS miembros
FROM grupo g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo, g.categoria;

-- Borrador Consulta 4: Próximos eventos
SELECT titulo_evento, tipo_evento, fecha_evento, lugar
FROM evento
WHERE fecha_evento >= CURRENT_DATE;

-- Borrador Consulta 5: Estudiantes sin grupos
SELECT e.id_estudiante, e.nombre, e.apellido
FROM estudiante e
WHERE NOT EXISTS (
    SELECT 1 FROM miembro_grupo mg WHERE mg.id_estudiante = e.id_estudiante
);

-- Borrador Vista 1
CREATE OR REPLACE VIEW vw_mentores_borrador AS
SELECT e.id_estudiante, e.nombre, e.apellido, p.nombre_programa
FROM estudiante e
JOIN programa_academico p ON e.id_programa = p.id_programa
WHERE e.disponible_mentoria = TRUE;
