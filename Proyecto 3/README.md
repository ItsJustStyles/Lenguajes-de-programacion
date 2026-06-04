# Chatbot Inteligente con Programación Lógica

Chatbot conversacional desarrollado íntegramente en el paradigma lógico usando **SWI-Prolog**. El sistema combina una base de conocimiento declarativa, un motor de inferencia automática y la capacidad de aprender nuevos hechos en tiempo de ejecución, persistiéndolos entre sesiones.

**Autores:** Federick Fernández Calderón · Justin Lacayo Picado · Josimar Araya Smith  
**Curso:** Lenguajes de Programación — I Semestre 2026  

---

## Ejecución rápida

```bash
swipl src/main.pl
```

Requiere [SWI-Prolog](https://www.swi-prolog.org/) 8.0 o superior.

---

## 1. Arquitectura lógica

El sistema se divide en seis módulos Prolog. Cada uno tiene una responsabilidad única y se comunica con los demás únicamente a través de predicados públicos bien definidos.

```
main.pl
  ├── knowledge_base.pl   (datos + reglas de inferencia base)
  ├── inference.pl        (motor de respuestas)
  ├── query_processor.pl  (normalización y detección de intención)
  ├── learning.pl         (aprendizaje dinámico y persistencia)
  └── conversation.pl     (flujo conversacional y estado)
```

### Descripción de cada módulo

| Módulo | Responsabilidad |
|--------|----------------|
| `main.pl` | Punto de entrada. Loop de consola, lectura/normalización de entrada, despacho al módulo de conversación. |
| `knowledge_base.pl` | 50+ hechos declarativos organizados en 7 tipos de predicados (`concepto/2`, `definicion/2`, `es_un/2`, `parte_de/2`, `propiedad/2`, `relacionado/2`, `sinonimo/2`) y 6 reglas base de inferencia. |
| `inference.pl` | Predicado central `obtener_respuesta/2`. Detecta la intención (vía `query_processor.pl`) y despacha a los predicados de respuesta específicos (`responder_definicion`, `responder_propiedades`, etc.). |
| `query_processor.pl` | Normaliza texto (tildes, mayúsculas, puntuación), detecta intención del usuario mediante palabras clave y detecta términos en la entrada. |
| `learning.pl` | Permite enseñar (`aprende`) y olvidar (`olvida`) hechos en tiempo de ejecución con `assertz/retract`. Persiste los hechos aprendidos en `learned_facts.pl` entre sesiones. |
| `conversation.pl` | Mantiene el estado de la conversación activa, elige mensajes de bienvenida/despedida al azar y delega cada turno al módulo correcto (aprendizaje vs. consulta). |

---

## 2. Explicación del funcionamiento

### 2.1 Ciclo de vida de una consulta

```
Usuario escribe: "define prolog"
        │
        ▼
main.pl: leer_entrada/1
  • read_line_to_string
  • string_lower
  • split_string → lista de átomos: [define, prolog]
        │
        ▼
conversation.pl: manejar_turno/1
  • Detecta si es comando de aprendizaje/olvido → no
  • Llama a obtener_respuesta/2
        │
        ▼
inference.pl: obtener_respuesta/2
  • Llama a preparar_pregunta/3
        │
        ▼
query_processor.pl: procesar_pregunta/3
  • normalizar_pregunta → limpia tildes y puntuación
  • detectar_intencion → [define] ∈ palabras_definicion → intención: 'definicion'
  • detectar_terminos  → [prolog] reconocido en knowledge_base
  • Retorna: Intencion=definicion, Terminos=[prolog]
        │
        ▼
inference.pl: obtener_por_intencion(definicion, [prolog], Respuesta)
  • responder_definicion(prolog, R)
  • canonico(prolog, prolog)   (sin sinónimo)
  • definicion(prolog, Texto)  → encontrado
  • format → Respuesta = "prolog: Prolog es un lenguaje..."
        │
        ▼
conversation.pl: format('Bot: ~w~n', [Respuesta])
```

### 2.2 Inferencia transitiva de taxonomía

La regla `es_un_inferido/2` aplica backtracking para deducir relaciones heredadas:

```prolog
es_un_inferido(X, Y) :- es_un(X, Y).
es_un_inferido(X, Z) :- es_un(X, Y), es_un_inferido(Y, Z).
```

Ejemplo: `perro → mamifero → animal → ser_vivo`  
Al consultar "que es perro", el motor infiere automáticamente todos los niveles de la jerarquía.

### 2.3 Herencia de propiedades

```prolog
tiene_propiedad(X, P) :- propiedad(X, P).
tiene_propiedad(X, P) :- es_un_inferido(X, Ancestro), propiedad(Ancestro, P).
```

Un `perro` hereda `respira` y `se_mueve` de `animal`, y `nace/crece/muere` de `ser_vivo`, aunque ninguna de esas propiedades esté declarada directamente para el perro.

### 2.4 Resolución de sinónimos

Antes de buscar cualquier hecho, el sistema normaliza el término del usuario a su forma canónica:

```prolog
canonico(Termino, Canonico) :- sinonimo(Termino, Canonico), !.
canonico(Termino, Termino).
```

Así, "ia", "ai" y "inteligencia_artificial" son intercambiables.

### 2.5 Aprendizaje dinámico y persistencia

Cuando el usuario escribe `aprende que X es Y`:

1. `learning.pl` parsea el patrón para determinar el tipo de hecho (`concepto`, `es_un`, `parte_de`, etc.).
2. Llama a `ensenar_hecho/3` que valida, hace `assertz(Hecho)` y `assertz(hecho_aprendido(...))`.
3. Escribe el hecho en `learned_facts.pl` en el formato:
   ```prolog
   :- assertz(concepto(robot,'una maquina autonoma')).
   :- assertz(hecho_aprendido(concepto,robot,'una maquina autonoma')).
   ```
4. En la siguiente sesión, `inicializar_aprendizaje/0` carga ese archivo, restaurando tanto el hecho como su registro de tracking.

---

## 3. Ejemplos de uso

### Consultas básicas

```
Tu: que es prolog
Bot: prolog es un lenguaje de programación lógica. Por inferencia, tambien es
     un tipo de: herramienta informatica, lenguaje de programacion y software.

Tu: define inteligencia artificial
Bot: inteligencia artificial: La inteligencia artificial (IA) es la rama de la
     informática que estudia y desarrolla sistemas capaces de realizar tareas
     que normalmente requieren inteligencia humana...
```

### Variaciones de la misma pregunta

```
Tu: define prolog          → definición completa
Tu: explica prolog         → definición completa
Tu: describe prolog        → definición completa
Tu: que es prolog          → concepto + tipos inferidos
```

### Inferencia de propiedades

```
Tu: propiedades de perro
Bot: Por inferencia, perro tiene estas propiedades: amamanta crias, crece,
     muere, nace, respira, se mueve y tiene pelo.

Tu: propiedades de delfin
Bot: Por inferencia, delfin tiene estas propiedades: amamanta crias, crece,
     muere, nace, respira, se mueve y tiene pelo.
```

### Relaciones entre conceptos

```
Tu: relacion entre prolog y ia
Bot: inteligencia artificial se relaciona logicamente con prolog.

Tu: relacion entre cpu y computadora
Bot: Por inferencia de composicion, cpu es parte de computadora.
```

### Sinónimos

```
Tu: sinonimos de computadora
Bot: Estos terminos se pueden usar como sinonimos de computadora: compu,
     ordenador y pc.

Tu: que es la ia          → responde sobre inteligencia_artificial
Tu: que es el ml          → responde sobre machine_learning
```

### Aprendizaje dinámico

```
Tu: aprende que typescript es un tipo de lenguaje de programacion
Bot: Aprendido!

Tu: que es typescript
Bot: typescript es un tipo de: herramienta informatica, lenguaje de
     programacion y software.
```

### Olvidar un hecho

```
Tu: olvida que typescript es lenguaje de programacion
Bot: Entendido. He olvidado que typescript es lenguaje_de_programacion.
```

---

## 4. Cómo agregar nuevo conocimiento

### En tiempo de ejecución (sin editar código)

| Patrón | Efecto |
|--------|--------|
| `aprende que X es Y` | Registra `concepto(X, Y)` |
| `aprende que X es un Y` | Registra `es_un(X, Y)` |
| `aprende que X es un tipo de Y` | Registra `es_un(X, Y)` |
| `aprende que X es parte de Y` | Registra `parte_de(X, Y)` |
| `aprende que X es sinonimo de Y` | Registra `sinonimo(X, Y)` |
| `aprende que X se relaciona con Y` | Registra `relacionado(X, Y)` |
| `olvida que X es Y` | Elimina el hecho correspondiente |

### Editando directamente `knowledge_base.pl`

```prolog
% Nuevo concepto
concepto(rust, 'un lenguaje de programación de sistemas de alto rendimiento').

% Nueva relación taxonómica
es_un(rust, lenguaje_de_programacion).

% Nueva propiedad
propiedad(rust, garantiza_seguridad_de_memoria).

% Nuevo sinónimo
sinonimo(rs, rust).
```

### Tipos de predicados disponibles

| Predicado | Uso |
|-----------|-----|
| `concepto/2` | `concepto(Term, Desc)` — Descripción breve |
| `definicion/2` | `definicion(Term, Texto)` — Definición extensa |
| `es_un/2` | `es_un(Subtipo, Supertipo)` — Taxonomía (transitividad automática) |
| `parte_de/2` | `parte_de(Parte, Todo)` — Composición |
| `propiedad/2` | `propiedad(Sujeto, Prop)` — Característica (herencia automática) |
| `relacionado/2` | `relacionado(A, B)` — Asociación libre (simétrica automáticamente) |
| `sinonimo/2` | `sinonimo(Variante, Canonico)` — Equivalencia de vocabulario |

---

## Estructura del proyecto

```
Proyecto 3/
├── src/
│   ├── main.pl              # Punto de entrada y flujo conversacional
│   ├── knowledge_base.pl    # Base de conocimiento (Fase 2)
│   ├── inference.pl         # Sistema de inferencias (Fase 3)
│   ├── query_processor.pl   # Procesamiento de preguntas (Fase 4)
│   ├── learning.pl          # Aprendizaje dinámico (Fase 5)
│   ├── conversation.pl      # Flujo conversacional (Fase 6)
│   └── learned_facts.pl     # Hechos aprendidos (auto-generado)
├── DOCUMENTO_TEC.pdf        # Documento formal del proyecto
└── README.md
```
