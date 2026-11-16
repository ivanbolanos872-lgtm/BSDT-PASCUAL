# Diccionario de Datos y Estándares de Nomenclatura ALIAS
**Proyecto:** Red Social Estudiantil Pascualina  
**Motor de Base de Datos:** PostgreSQL 17 (pgAdmin 4)  
**Integrantes:** Deimar Copete, Iván Mauricio Bolaños  

---

## 1. Diccionario de Entidades Principales (Modelo Físico)

| Tabla | Columna | Tipo de Dato (PostgreSQL) | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `programa_academico` | `id_programa` | `SERIAL` | `PRIMARY KEY` | Identificador único del programa académico. |
| `programa_academico` | `nombre_programa` | `VARCHAR(120)` | `NOT NULL` | Nombre oficial de la carrera universitaria. |
| `programa_academico` | `facultad` | `VARCHAR(100)` | `NOT NULL` | Facultad a la que pertenece el programa. |
| `estudiante` | `id_estudiante` | `SERIAL` | `PRIMARY KEY` | Identificador único del estudiante. |
| `estudiante` | `nombre` | `VARCHAR(80)` | `NOT NULL` | Nombres del estudiante. |
| `estudiante` | `apellido` | `VARCHAR(80)` | `NOT NULL` | Apellidos del estudiante. |
| `estudiante` | `correo` | `VARCHAR(120)` | `UNIQUE, NOT NULL` | Correo electrónico institucional. |
| `estudiante` | `semestre` | `INT` | `CHECK (1..12)` | Semestre académico actual del estudiante. |
| `estudiante` | `disponible_mentoria` | `BOOLEAN` | `DEFAULT FALSE` | Indica si el estudiante ofrece mentorías. |
| `estudiante` | `estado_academico` | `VARCHAR(30)` | `DEFAULT 'Activo'` | Estado de matrícula (`Activo`, `Inactivo`). |
| `estudiante` | `id_programa` | `INT` | `FOREIGN KEY` | Referencia a `programa_academico(id_programa)`. |
| `habilidad` | `id_habilidad` | `SERIAL` | `PRIMARY KEY` | Identificador único de la habilidad o deporte. |
| `habilidad` | `nombre_habilidad` | `VARCHAR(80)` | `NOT NULL` | Nombre de la disciplina o tecnología. |
| `habilidad` | `categoria` | `VARCHAR(50)` | `NOT NULL` | Clasificación (`Bases de Datos`, `Programación`, etc.). |
| `publicacion` | `id_publicacion` | `SERIAL` | `PRIMARY KEY` | Identificador único de la publicación. |
| `publicacion` | `titulo` | `VARCHAR(150)` | `NOT NULL` | Encabezado de la publicación. |
| `publicacion` | `categoria` | `VARCHAR(50)` | `NOT NULL` | Tipo (`Recurso Útil`, `Noticia Tech`, `Pregunta`, `Meme`). |
| `publicacion` | `num_reacciones` | `INT` | `DEFAULT 0` | Contador acumulado de reacciones positivas. |
| `publicacion` | `id_estudiante` | `INT` | `FOREIGN KEY` | Autor de la publicación (`estudiante`). |
| `grupo` | `id_grupo` | `SERIAL` | `PRIMARY KEY` | Identificador único del grupo o club. |
| `grupo` | `nombre_grupo` | `VARCHAR(100)` | `NOT NULL` | Nombre del grupo de estudio o club. |
| `grupo` | `capacidad_maxima` | `INT` | `DEFAULT 30` | Cupo máximo permitido de integrantes. |
| `evento` | `id_evento` | `SERIAL` | `PRIMARY KEY` | Identificador único del evento programado. |
| `evento` | `fecha_evento` | `DATE` | `NOT NULL` | Fecha programada para el encuentro o taller. |

---

## 2. Reglas de Nomenclatura para Datos Calculados (`ALIAS`)

Para garantizar la legibilidad, mantenibilidad y compatibilidad con herramientas de Business Intelligence (BI) y reportes ejecutivos, el equipo estableció las siguientes reglas de nomenclatura:

1. **Formato PascalCase con Guion Bajo (`"Nombre_Calculado"`) en Consultas de Reporte:** Se utilizan comillas dobles en PostgreSQL para preservar mayúsculas iniciales y guiones bajos sin espacios, facilitando la lectura directa en tablas de salida (`"Nombre_Mentor"`, `"Indice_Interaccion"`, `"Porcentaje_Ocupacion"`).
2. **Formato snake_case en Vistas (`nombre_columna`):** Dentro de las vistas (`CREATE VIEW`), los alias se definen en minúsculas (`snake_case`) sin comillas dobles (`nombre_completo_mentor`, `tasa_ocupacion_pct`, `puntaje_impacto_total`) para permitir que consultas posteriores invoquen las columnas de la vista sin sensibilidad a mayúsculas/minúsculas.
3. **Sufijos Semánticos:**
   * `_pct`: Indica valores porcentuales redondeados a 2 decimales (`tasa_ocupacion_pct`).
   * `total_` / `suma_`: Indica funciones de agregación `COUNT` o `SUM` (`total_miembros_activos`, `suma_reacciones`).
   * `indice_` / `puntaje_`: Indica métricas compuestas calculadas a partir de dos o más columnas (`Indice_Interaccion`, `puntaje_impacto_total`).
