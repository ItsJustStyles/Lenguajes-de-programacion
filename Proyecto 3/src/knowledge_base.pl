% ============================================================================
% knowledge_base.pl - Base de Conocimiento del Chatbot Inteligente
% ----------------------------------------------------------------------------
% Proyecto 3: Chatbot Inteligente con Programacion Logica
% Paradigma Logico - I Semestre 2026
%
% FASE 2: Base de Conocimiento (minimo 50 hechos/reglas)
%
% Este modulo concentra TODO el conocimiento declarativo del chatbot:
%   - concepto/2     : conceptos breves          (que ES algo, en una linea)
%   - definicion/2   : definiciones extensas      (explicacion completa)
%   - es_un/2        : relaciones de taxonomia     (X es un tipo de Y)
%   - parte_de/2     : relaciones de composicion   (X es parte de Y)
%   - propiedad/2    : asociaciones / caracteristicas (X tiene la propiedad Y)
%   - relacionado/2  : asociaciones logicas libres (X se relaciona con Y)
%   - sinonimo/2     : equivalencias de vocabulario
%
% Ademas incluye REGLAS BASICAS DE INFERENCIA que derivan conocimiento nuevo
% a partir de los hechos (transitividad, simetria, herencia de propiedades).
%
% Todos los predicados de datos se declaran 'dynamic' para que la Fase 5
% (aprendizaje dinamico) pueda extender la base con assertz/1 en tiempo de
% ejecucion sin modificar el codigo fuente.
% ============================================================================

:- set_prolog_flag(encoding, utf8).

% --- Declaracion de predicados dinamicos (ampliables por aprendizaje) -------
:- dynamic concepto/2.
:- dynamic definicion/2.
:- dynamic es_un/2.
:- dynamic parte_de/2.
:- dynamic propiedad/2.
:- dynamic relacionado/2.
:- dynamic sinonimo/2.

% ============================================================================
% 1. CONCEPTOS  -  concepto(Termino, DescripcionBreve)
% ----------------------------------------------------------------------------
% Respuesta corta a "que es X". Una sola idea por hecho.
% ============================================================================

concepto(prolog,                'un lenguaje de programación lógica').
concepto(python,                'un lenguaje de programación de propósito general').
concepto(java,                  'un lenguaje de programación orientado a objetos').
concepto(algoritmo,             'una secuencia ordenada de pasos para resolver un problema').
concepto(variable,              'un espacio con nombre que almacena un valor').
concepto(funcion,               'un bloque de código reutilizable que realiza una tarea').
concepto(recursividad,          'una técnica donde un predicado o función se llama a sí mismo').
concepto(compilador,            'un programa que traduce código fuente a código máquina').
concepto(interprete,            'un programa que ejecuta código fuente directamente').
concepto(base_de_datos,         'una colección organizada de datos almacenados').
concepto(inteligencia_artificial,'la disciplina que crea sistemas capaces de simular la inteligencia humana').
concepto(chatbot,               'un programa que conversa con personas en lenguaje natural').
concepto(hecho,                 'una afirmación que se considera verdadera en Prolog').
concepto(regla,                 'una afirmación condicional que deriva nuevos hechos').
concepto(unificacion,           'el proceso por el que Prolog hace coincidir dos términos').
concepto(backtracking,          'el mecanismo de Prolog para buscar soluciones alternativas').
concepto(perro,                 'un animal mamífero doméstico').
concepto(gato,                  'un animal mamífero doméstico de la familia de los felinos').
concepto(computadora,           'una máquina electrónica que procesa datos').
concepto(internet,              'una red global que conecta computadoras de todo el mundo').

% ============================================================================
% 2. DEFINICIONES  -  definicion(Termino, ExplicacionExtensa)
% ----------------------------------------------------------------------------
% Texto mas completo para cuando el usuario pide "defíneme X" o "explícame X".
% ============================================================================

definicion(inteligencia_artificial,
    'La inteligencia artificial (IA) es la rama de la informática que estudia y desarrolla sistemas capaces de realizar tareas que normalmente requieren inteligencia humana, como razonar, aprender, percibir y tomar decisiones.').
definicion(prolog,
    'Prolog es un lenguaje de programación lógica basado en la lógica de predicados de primer orden. El programador describe hechos y reglas, y el sistema responde consultas mediante inferencia y backtracking.').
definicion(paradigma_logico,
    'El paradigma lógico es un estilo de programación declarativo en el que se expresa QUÉ se quiere resolver mediante hechos y reglas, y el motor de inferencia se encarga de CÓMO obtener la respuesta.').
definicion(recursividad,
    'La recursividad es una técnica en la que un predicado se define en términos de sí mismo, con al menos un caso base que detiene las llamadas y un caso recursivo que se acerca a él.').
definicion(algoritmo,
    'Un algoritmo es un conjunto finito y ordenado de instrucciones bien definidas que permiten resolver un problema o realizar una tarea en un número finito de pasos.').
definicion(machine_learning,
    'El aprendizaje automático (machine learning) es una rama de la inteligencia artificial que permite a las computadoras aprender patrones a partir de datos sin ser programadas explícitamente para cada caso.').
definicion(unificacion,
    'La unificación es el mecanismo central de Prolog que intenta hacer idénticos dos términos encontrando una sustitución de variables que los iguale.').
definicion(backtracking,
    'El backtracking es el proceso por el cual Prolog, al fallar un objetivo, retrocede al último punto de decisión y prueba otra alternativa hasta encontrar una solución o agotarlas todas.').

% ============================================================================
% 3. RELACIONES DE TAXONOMIA  -  es_un(Subtipo, Supertipo)
% ----------------------------------------------------------------------------
% "X es un tipo de Y". Forma una jerarquia que habilita herencia por reglas.
% ============================================================================

es_un(perro,        mamifero).
es_un(gato,         mamifero).
es_un(delfin,       mamifero).
es_un(aguila,       ave).
es_un(pinguino,     ave).
es_un(mamifero,     animal).
es_un(ave,          animal).
es_un(animal,       ser_vivo).
es_un(planta,       ser_vivo).
es_un(prolog,       lenguaje_de_programacion).
es_un(python,       lenguaje_de_programacion).
es_un(java,         lenguaje_de_programacion).
es_un(lenguaje_de_programacion, herramienta_informatica).
es_un(machine_learning,         inteligencia_artificial).
es_un(chatbot,                  inteligencia_artificial).

% ============================================================================
% 4. RELACIONES DE COMPOSICION  -  parte_de(Parte, Todo)
% ============================================================================

parte_de(cpu,           computadora).
parte_de(memoria_ram,   computadora).
parte_de(disco_duro,    computadora).
parte_de(hecho,         base_de_conocimiento).
parte_de(regla,         base_de_conocimiento).
parte_de(motor,         carro).
parte_de(rueda,         carro).

% ============================================================================
% 5. PROPIEDADES / ASOCIACIONES  -  propiedad(Sujeto, Caracteristica)
% ----------------------------------------------------------------------------
% Caracteristicas que luego se HEREDAN por la jerarquia es_un mediante reglas.
% ============================================================================

propiedad(ser_vivo,     nace).
propiedad(ser_vivo,     crece).
propiedad(ser_vivo,     muere).
propiedad(animal,       se_mueve).
propiedad(animal,       respira).
propiedad(mamifero,     tiene_pelo).
propiedad(mamifero,     amamanta_crias).
propiedad(ave,          tiene_plumas).
propiedad(ave,          pone_huevos).
propiedad(prolog,       es_declarativo).
propiedad(prolog,       usa_backtracking).
propiedad(python,       es_interpretado).

% ============================================================================
% 6. ASOCIACIONES LOGICAS LIBRES  -  relacionado(A, B)
% ----------------------------------------------------------------------------
% Conexiones tematicas entre conceptos (no jerarquicas). Son simetricas:
% una regla mas abajo deriva relacionado(B, A) automaticamente.
% ============================================================================

relacionado(prolog,             paradigma_logico).
relacionado(prolog,             inteligencia_artificial).
relacionado(inteligencia_artificial, machine_learning).
relacionado(chatbot,            inteligencia_artificial).
relacionado(algoritmo,          programacion).
relacionado(recursividad,       prolog).
relacionado(base_de_datos,      informacion).

% ============================================================================
% 7. SINONIMOS  -  sinonimo(Variante, TerminoCanonico)
% ----------------------------------------------------------------------------
% Permiten que el chatbot reconozca distintas formas de nombrar lo mismo.
% La Fase 4 los usara para normalizar la entrada del usuario.
% ============================================================================

sinonimo(ia,                inteligencia_artificial).
sinonimo(ai,                inteligencia_artificial).
sinonimo(ml,                machine_learning).
sinonimo(aprendizaje_automatico, machine_learning).
sinonimo(pc,                computadora).
sinonimo(ordenador,         computadora).
sinonimo(compu,             computadora).
sinonimo(can,               perro).
sinonimo(felino,            gato).
sinonimo(programa,          algoritmo).

% ============================================================================
% ============================================================================
%   REGLAS BASICAS DE INFERENCIA
% ----------------------------------------------------------------------------
% Derivan conocimiento NUEVO que no esta escrito explicitamente como hecho.
% Esta es la esencia del paradigma logico: el motor deduce las respuestas.
% ============================================================================
% ============================================================================

% --- 8.1 Transitividad de la taxonomia --------------------------------------
% es_un_inferido/2: ademas de los es_un directos, deduce los heredados.
% Ej.: perro es_un mamifero, mamifero es_un animal  =>  perro es_un animal.
es_un_inferido(X, Y) :-
    es_un(X, Y).
es_un_inferido(X, Z) :-
    es_un(X, Y),
    es_un_inferido(Y, Z).

% --- 8.2 Herencia de propiedades por la jerarquia ---------------------------
% tiene_propiedad/2: un individuo posee sus propiedades directas Y todas las
% de sus ancestros. Ej.: un perro 'respira' porque es_un animal.
tiene_propiedad(X, P) :-
    propiedad(X, P).
tiene_propiedad(X, P) :-
    es_un_inferido(X, Ancestro),
    propiedad(Ancestro, P).

% --- 8.3 Simetria de las asociaciones libres --------------------------------
% se_relaciona/2: relacionado/2 vale en ambos sentidos.
se_relaciona(A, B) :- relacionado(A, B).
se_relaciona(A, B) :- relacionado(B, A).

% --- 8.4 Simetria y reflexividad de sinonimos -------------------------------
% mismo_significado/2: dos terminos son equivalentes si uno es sinonimo del
% otro (en cualquier direccion) o si son el mismo termino.
mismo_significado(X, X).
mismo_significado(X, Y) :- sinonimo(X, Y).
mismo_significado(X, Y) :- sinonimo(Y, X).

% --- 8.5 Termino canonico ---------------------------------------------------
% canonico/2: reduce una variante a su termino oficial usando los sinonimos.
% Si no hay sinonimo registrado, el termino es su propio canonico.
canonico(Termino, Canonico) :-
    sinonimo(Termino, Canonico), !.
canonico(Termino, Termino).

% --- 8.6 Conocimiento sobre un termino --------------------------------------
% se_conoce/1: verdadero si la base tiene ALGUNA informacion sobre el termino.
% Util para que el chatbot decida si responder o admitir que no sabe.
se_conoce(T) :- concepto(T, _), !.
se_conoce(T) :- definicion(T, _), !.
se_conoce(T) :- es_un(T, _), !.
se_conoce(T) :- es_un(_, T), !.
se_conoce(T) :- propiedad(T, _), !.
se_conoce(T) :- relacionado(T, _), !.
se_conoce(T) :- relacionado(_, T), !.
