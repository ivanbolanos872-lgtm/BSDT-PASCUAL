-- ============================================================================
-- PROYECTO: Red Social Estudiantil Pascualina
-- ARCHIVO: 03_final_dml_vistas_comentado.sql
-- DESCRIPCIÓN: Versión final depurada y comentada de las 5 consultas DML de negocio
--              y las 3 vistas analíticas (VIEWS) con nomenclatura estándar ALIAS.
-- DBMS: PostgreSQL 17 / pgAdmin 4
-- AUTORES: Deimar Copete, Iván Mauricio Bolaños
-- ============================================================================

-- ============================================================================
-- PARTE 1: CINCO (5) CONSULTAS DML DE NEGOCIO
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONSULTA 1: Directorio de Mentores Académicos Calificados
-- Pregunta de negocio: ¿Qué estudiantes de semestres avanzados (semestre >= 6) 
-- están disponibles para brindar mentoría y cuáles son sus habilidades técnicas?
-- ----------------------------------------------------------------------------
SELECT 
    e.id_estudiante AS "ID_Estudiante",                                -- Identificador único del mentor
    e.nombre || ' ' || e.apellido AS "Nombre_Mentor",                  -- Nombre completo concatenado
    pa.nombre_programa AS "Programa_Academico",                        -- Programa al que pertenece
    e.semestre AS "Semestre_Actual",                                   -- Semestre cursado
    h.nombre_habilidad AS "Habilidad_Tecnica",                         -- Competencia registrada
    eh.nivel AS "Nivel_Dominio"                                        -- Nivel de experiencia
FROM estudiante AS e                                                   -- Tabla principal de estudiantes
INNER JOIN programa_academico AS pa ON e.id_programa = pa.id_programa  -- Unión con programas académicos
INNER JOIN estudiante_habilidad AS eh ON e.id_estudiante = eh.id_estudiante -- Unión con habilidades asignadas
INNER JOIN habilidad AS h ON eh.id_habilidad = h.id_habilidad          -- Unión con catálogo de habilidades
WHERE e.semestre >= 6                                                  -- Filtro de semestres avanzados
  AND e.disponible_mentoria = TRUE                                     -- Solo mentores activos
  AND e.estado_academico = 'Activo'                                    -- Estudiantes matriculados activos
ORDER BY e.semestre DESC, "Nombre_Mentor" ASC;                         -- Ordena por mayor experiencia y nombre

-- ----------------------------------------------------------------------------
-- CONSULTA 2: Publicaciones Académicas de Alto Impacto (Engagement)
-- Pregunta de negocio: ¿Cuáles son las publicaciones sobre recursos útiles o 
-- noticias tecnológicas que superan el promedio general de reacciones?
-- ----------------------------------------------------------------------------
SELECT 
    pub.id_publicacion AS "ID_Publicacion",                            -- Identificador de la publicación
    pub.titulo AS "Titulo_Publicacion",                                -- Título del aporte
    pub.categoria AS "Categoria_Contenido",                            -- Tipo de publicación
    e.nombre || ' ' || e.apellido AS "Autor_Publicacion",              -- Autor de la publicación
    pub.num_reacciones AS "Total_Reacciones",                          -- Cantidad de reacciones
    COUNT(c.id_comentario) AS "Total_Comentarios",                     -- Conteo de comentarios recibidos
    (pub.num_reacciones + COUNT(c.id_comentario)) AS "Indice_Interaccion" -- Métrica calculada de engagement
FROM publicacion AS pub                                                -- Tabla de publicaciones
INNER JOIN estudiante AS e ON pub.id_estudiante = e.id_estudiante      -- Unión con el autor
LEFT JOIN comentario AS c ON pub.id_publicacion = c.id_publicacion     -- Unión externa para incluir posts sin comentarios
WHERE pub.categoria IN ('Recurso Útil', 'Noticia Tech')                -- Filtra contenido académico/tecnológico
GROUP BY pub.id_publicacion, pub.titulo, pub.categoria, e.nombre, e.apellido, pub.num_reacciones
HAVING pub.num_reacciones > (                                          -- Subconsulta escalar para comparar contra el promedio
    SELECT AVG(num_reacciones) FROM publicacion
)
ORDER BY "Indice_Interaccion" DESC;                                    -- Prioriza mayor interacción total

-- ----------------------------------------------------------------------------
-- CONSULTA 3: Analítica de Ocupación y Participación en Grupos/Clubes
-- Pregunta de negocio: ¿Cuántos miembros activos tiene cada grupo o club de 
-- interés y cuál es su porcentaje de ocupación respecto a su capacidad máxima?
-- ----------------------------------------------------------------------------
SELECT 
    g.id_grupo AS "ID_Grupo",                                          -- Identificador del grupo
    g.nombre_grupo AS "Nombre_Comunidad",                              -- Nombre del grupo o club
    g.categoria AS "Categoria_Grupo",                                  -- Temática del grupo
    COUNT(mg.id_estudiante) AS "Miembros_Activos",                     -- Total de integrantes activos
    g.capacidad_maxima AS "Cupo_Maximo",                               -- Límite de integrantes
    ROUND((COUNT(mg.id_estudiante)::NUMERIC / g.capacidad_maxima) * 100, 2) AS "Porcentaje_Ocupacion" -- % calculado
FROM grupo AS g                                                        -- Tabla de grupos
LEFT JOIN miembro_grupo AS mg                                          -- Unión externa para ver grupos incluso vacíos
    ON g.id_grupo = mg.id_grupo AND mg.estado = 'Activo'               -- Solo cuenta membresías activas
GROUP BY g.id_grupo, g.nombre_grupo, g.categoria, g.capacidad_maxima
ORDER BY "Porcentaje_Ocupacion" DESC, "Nombre_Comunidad" ASC;          -- Ordena por mayor demanda

-- ----------------------------------------------------------------------------
-- CONSULTA 4: Agenda de Eventos Próximos y Estado de Convocatoria
-- Pregunta de negocio: ¿Qué talleres, hackatones o reuniones de estudio están 
-- programados próximamente, cuántos días faltan y cuántos asistentes tienen?
-- ----------------------------------------------------------------------------
SELECT 
    ev.id_evento AS "ID_Evento",                                       -- Identificador del evento
    ev.titulo_evento AS "Nombre_Evento",                               -- Título del evento
    ev.tipo_evento AS "Modalidad",                                     -- Tipo de actividad
    ev.fecha_evento AS "Fecha_Programada",                             -- Fecha de realización
    (ev.fecha_evento - CURRENT_DATE) AS "Dias_Restantes",              -- Cálculo de días faltantes
    COUNT(ae.id_estudiante) AS "Asistentes_Confirmados",               -- Conteo de inscritos
    CASE                                                               -- Clasificación dinámica de urgencia
        WHEN (ev.fecha_evento - CURRENT_DATE) <= 3 THEN 'Inminente (Menos de 3 días)'
        WHEN (ev.fecha_evento - CURRENT_DATE) <= 7 THEN 'Esta Semana'
        ELSE 'Próximamente'
    END AS "Estado_Convocatoria"                                       -- Etiqueta calculada
FROM evento AS ev                                                      -- Tabla de eventos
LEFT JOIN asistencia_evento AS ae                                      -- Unión con asistencias
    ON ev.id_evento = ae.id_evento AND ae.estado_asistencia = 'Confirmado'
WHERE ev.fecha_evento >= CURRENT_DATE                                  -- Solo eventos vigentes o futuros
GROUP BY ev.id_evento, ev.titulo_evento, ev.tipo_evento, ev.fecha_evento
ORDER BY "Dias_Restantes" ASC;                                         -- Muestra primero los más cercanos

-- ----------------------------------------------------------------------------
-- CONSULTA 5: Detección de Estudiantes Aislados (Sin Grupos ni Conexiones)
-- Pregunta de negocio: ¿Qué estudiantes registrados aún no pertenecen a ningún 
-- grupo ni siguen a otros compañeros, para sugerirles redes iniciales?
-- ----------------------------------------------------------------------------
SELECT 
    e.id_estudiante AS "ID_Estudiante",                                -- Identificador del estudiante
    e.nombre || ' ' || e.apellido AS "Estudiante_Sin_Red",             -- Nombre completo
    e.correo AS "Correo_Institucional",                                -- Contacto institucional
    pa.nombre_programa AS "Programa_Academico",                        -- Carrera que cursa
    e.semestre AS "Semestre"                                           -- Semestre actual
FROM estudiante AS e                                                   -- Tabla principal de estudiantes
INNER JOIN programa_academico AS pa ON e.id_programa = pa.id_programa  -- Unión con programa académico
WHERE NOT EXISTS (                                                     -- Verifica que no tenga membresías en grupos
    SELECT 1 
    FROM miembro_grupo AS mg 
    WHERE mg.id_estudiante = e.id_estudiante
)
AND NOT EXISTS (                                                       -- Verifica que no siga a ningún compañero
    SELECT 1 
    FROM seguidor AS s 
    WHERE s.id_seguidor = e.id_estudiante
)
ORDER BY e.semestre ASC, "Estudiante_Sin_Red" ASC;                     -- Prioriza estudiantes de primeros semestres


-- ============================================================================
-- PARTE 2: CREACIÓN DE TRES (3) VISTAS ANALÍTICAS (VIEWS)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VISTA 1: vw_directorio_mentores
-- Objetivo: Consolidar el perfil académico y técnico de los estudiantes aptos
-- para brindar mentorías en la red social pascualina.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_directorio_mentores AS
SELECT 
    e.id_estudiante AS id_mentor,
    e.nombre || ' ' || e.apellido AS nombre_completo_mentor,
    e.correo AS correo_contacto,
    pa.nombre_programa AS programa_academico,
    pa.facultad AS facultad,
    e.semestre AS semestre_actual,
    h.nombre_habilidad AS especialidad,
    h.categoria AS area_conocimiento,
    eh.nivel AS nivel_dominio
FROM estudiante AS e
INNER JOIN programa_academico AS pa ON e.id_programa = pa.id_programa
INNER JOIN estudiante_habilidad AS eh ON e.id_estudiante = eh.id_estudiante
INNER JOIN habilidad AS h ON eh.id_habilidad = h.id_habilidad
WHERE e.disponible_mentoria = TRUE 
  AND e.estado_academico = 'Activo';

-- Consulta de verificación Vista 1:
SELECT * FROM vw_directorio_mentores ORDER BY semestre_actual DESC;


-- ----------------------------------------------------------------------------
-- VISTA 2: vw_analitica_grupos_activos
-- Objetivo: Consolidar indicadores de tamaño, líder y eventos organizados por
-- cada grupo o club estudiantil para evaluar el dinamismo comunitario.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_analitica_grupos_activos AS
SELECT 
    g.id_grupo,
    g.nombre_grupo,
    g.categoria AS tipo_comunidad,
    lider.nombre || ' ' || lider.apellido AS nombre_lider,
    g.capacidad_maxima,
    COUNT(DISTINCT mg.id_estudiante) AS total_miembros_activos,
    COUNT(DISTINCT ev.id_evento) AS total_eventos_organizados,
    ROUND((COUNT(DISTINCT mg.id_estudiante)::NUMERIC / g.capacidad_maxima) * 100, 2) AS tasa_ocupacion_pct
FROM grupo AS g
INNER JOIN estudiante AS lider ON g.id_creador = lider.id_estudiante
LEFT JOIN miembro_grupo AS mg ON g.id_grupo = mg.id_grupo AND mg.estado = 'Activo'
LEFT JOIN evento AS ev ON g.id_grupo = ev.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo, g.categoria, lider.nombre, lider.apellido, g.capacidad_maxima;

-- Consulta de verificación Vista 2:
SELECT * FROM vw_analitica_grupos_activos ORDER BY tasa_ocupacion_pct DESC;


-- ----------------------------------------------------------------------------
-- VISTA 3: vw_impacto_publicaciones_academicas
-- Objetivo: Medir el alcance e interacción de las publicaciones por estudiante
-- y facultad para identificar líderes de opinión y creadores de recursos.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_impacto_publicaciones_academicas AS
SELECT 
    pa.facultad,
    pa.nombre_programa AS programa_academico,
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS autor,
    COUNT(DISTINCT pub.id_publicacion) AS cantidad_publicaciones,
    COALESCE(SUM(pub.num_reacciones), 0) AS suma_reacciones,
    COUNT(DISTINCT c.id_comentario) AS suma_comentarios_recibidos,
    (COALESCE(SUM(pub.num_reacciones), 0) + COUNT(DISTINCT c.id_comentario)) AS puntaje_impacto_total
FROM estudiante AS e
INNER JOIN programa_academico AS pa ON e.id_programa = pa.id_programa
LEFT JOIN publicacion AS pub ON e.id_estudiante = pub.id_estudiante
LEFT JOIN comentario AS c ON pub.id_publicacion = c.id_publicacion
GROUP BY pa.facultad, pa.nombre_programa, e.id_estudiante, e.nombre, e.apellido;

-- Consulta de verificación Vista 3:
SELECT * FROM vw_impacto_publicaciones_academicas ORDER BY puntaje_impacto_total DESC;
