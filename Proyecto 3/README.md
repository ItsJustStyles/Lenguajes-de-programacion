# Proyecto 3: Chatbot Inteligente con Programación Lógica

Chatbot conversacional desarrollado en **SWI-Prolog** que aplica los principios
del paradigma lógico: representación del conocimiento, inferencias lógicas,
reglas declarativas, manejo dinámico de hechos y procesamiento básico de
lenguaje natural.

El sistema mantiene conversaciones simples por consola, responde preguntas a
partir de una base de conocimiento inicial y **aprende nueva información**
durante la ejecución.

## Características

- Base de conocimiento inicial (conceptos, relaciones, definiciones, sinónimos).
- Conversación interactiva por consola.
- Aprendizaje dinámico mediante `assertz/1`.
- Manejo de sinónimos y variaciones de preguntas.
- Inferencias lógicas a partir de reglas declarativas.

## Requisitos

- [SWI-Prolog](https://www.swi-prolog.org/) 9.0 o superior.

Verificá la instalación con:

```bash
swipl --version
```

## Ejecución

Desde la raíz del `Proyecto 3`:

```bash
swipl src/main.pl
```

El chatbot inicia automáticamente. Escribí tus mensajes y usá `salir`
(o `adios`, `chao`, `exit`) para terminar la conversación.

## Estructura del proyecto

```
Proyecto 3/
├── src/
│   ├── main.pl              # Punto de entrada y flujo conversacional
│   ├── knowledge_base.pl    # Base de conocimiento (Fase 2)
│   ├── inference.pl         # Sistema de inferencias (Fase 3)
│   ├── query_processor.pl   # Procesamiento de preguntas (Fase 4)
│   └── learning.pl          # Aprendizaje dinámico (Fase 5)
├── README.md
└── Proyectos_Proyecto_3_*.pdf  # Enunciado
```

## Estado de desarrollo

- [x] **Fase 1** — Estructura base y bucle conversacional.
- [ ] **Fase 2** — Base de conocimiento inicial (50+ hechos/reglas).
- [ ] **Fase 3** — Sistema de inferencias lógicas.
- [ ] **Fase 4** — Manejo de variaciones y sinónimos.
- [ ] **Fase 5** — Aprendizaje dinámico.
- [ ] **Fase 6** — Documentación final.
