% PREDICADO PRINCIPAL

obtener_respuesta(Pregunta, Respuesta) :-
    preparar_pregunta(Pregunta, Intencion, Terminos),
    obtener_por_intencion(Intencion, Terminos, Respuesta),
    !.
obtener_respuesta(_, Respuesta) :-
    Respuesta = 'No tengo informacion suficiente sobre eso. Puedes ensenarme mas adelante con la fase de aprendizaje dinamico.'.

preparar_pregunta(Pregunta, Intencion, Terminos) :-
    current_predicate(procesar_pregunta/3),
    procesar_pregunta(Pregunta, Intencion, Terminos),
    !.
preparar_pregunta(Pregunta, consulta_general, Terminos) :-
    normalizar_basico(Pregunta, Palabras),
    extraer_terminos_basico(Palabras, Terminos).





% ============================================================================
% RESPUESTAS POR INTENCION
% ============================================================================

obtener_por_intencion(saludo, _, 'Hola. Puedes preguntarme por conceptos, definiciones, relaciones, sinonimos o propiedades.').

obtener_por_intencion(definicion, [Termino|_], Respuesta) :-
    responder_definicion(Termino, Respuesta).

obtener_por_intencion(consulta_tipo, [Termino|_], Respuesta) :-
    responder_concepto_o_tipo(Termino, Respuesta).

obtener_por_intencion(utilidad, [Termino|_], Respuesta) :-
    responder_utilidad(Termino, Respuesta).

obtener_por_intencion(propiedades, [Termino|_], Respuesta) :-
    responder_propiedades(Termino, Respuesta).

obtener_por_intencion(relacion, [A, B|_], Respuesta) :-
    responder_relacion_entre(A, B, Respuesta).
obtener_por_intencion(relacion, [Termino|_], Respuesta) :-
    responder_relaciones_de(Termino, Respuesta).

obtener_por_intencion(sinonimo, [Termino|_], Respuesta) :-
    responder_sinonimos(Termino, Respuesta).

obtener_por_intencion(consulta_general, [Termino|_], Respuesta) :-
    responder_resumen(Termino, Respuesta).

obtener_por_intencion(_, [], 'No encontre una palabra clave conocida en tu pregunta. Intenta preguntar por Prolog, IA, recursividad, perro, gato, computadora u otro concepto registrado.').






% RESPUESTAS ESPECIFICAS

responder_definicion(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    definicion(Canonico, Definicion),
    texto_termino(Canonico, Texto),
    format(atom(Respuesta), '~w: ~w', [Texto, Definicion]).
responder_definicion(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    concepto(Canonico, Concepto),
    texto_termino(Canonico, Texto),
    format(atom(Respuesta), '~w es ~w.', [Texto, Concepto]).

responder_concepto_o_tipo(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    concepto(Canonico, Concepto),
    tipos_de(Canonico, Tipos),
    texto_termino(Canonico, Texto),
    texto_lista(Tipos, TiposTexto),
    construir_respuesta_con_tipos(Texto, Concepto, TiposTexto, Respuesta).
responder_concepto_o_tipo(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    tipos_de(Canonico, Tipos),
    Tipos \= [],
    texto_termino(Canonico, Texto),
    texto_lista(Tipos, TiposTexto),
    format(atom(Respuesta), '~w es un tipo de: ~w.', [Texto, TiposTexto]).

construir_respuesta_con_tipos(Texto, Concepto, '', Respuesta) :-
    format(atom(Respuesta), '~w es ~w.', [Texto, Concepto]).
construir_respuesta_con_tipos(Texto, Concepto, TiposTexto, Respuesta) :-
    TiposTexto \= '',
    format(atom(Respuesta), '~w es ~w. Por inferencia, tambien es un tipo de: ~w.', [Texto, Concepto, TiposTexto]).

responder_utilidad(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    es_un_inferido(Canonico, lenguaje_de_programacion),
    texto_termino(Canonico, Texto),
    format(atom(Respuesta), '~w sirve como lenguaje de programacion. En la base se clasifica como herramienta informatica y puede relacionarse con otros conceptos mediante reglas logicas.', [Texto]).
responder_utilidad(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    relaciones_de(Canonico, Relaciones),
    Relaciones \= [],
    texto_termino(Canonico, Texto),
    texto_lista(Relaciones, RelacionesTexto),
    format(atom(Respuesta), 'No tengo una utilidad directa registrada para ~w, pero se relaciona con: ~w.', [Texto, RelacionesTexto]).
responder_utilidad(Termino, Respuesta) :-
    responder_resumen(Termino, Respuesta).

responder_propiedades(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    propiedades_de(Canonico, Propiedades),
    Propiedades \= [],
    texto_termino(Canonico, Texto),
    texto_lista(Propiedades, PropiedadesTexto),
    format(atom(Respuesta), 'Por inferencia, ~w tiene estas propiedades: ~w.', [Texto, PropiedadesTexto]).

responder_relacion_entre(A, B, Respuesta) :-
    canonico(A, CA),
    canonico(B, CB),
    relacion_directa_o_inferida(CA, CB, Respuesta),
    !.
responder_relacion_entre(A, B, Respuesta) :-
    texto_termino(A, TA),
    texto_termino(B, TB),
    format(atom(Respuesta), 'No encontre una relacion directa o inferida entre ~w y ~w.', [TA, TB]).

responder_relaciones_de(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    relaciones_de(Canonico, Relaciones),
    partes_de(Canonico, Partes),
    contenedores_de(Canonico, Contenedores),
    tipos_de(Canonico, Tipos),
    append(Relaciones, Partes, R1),
    append(R1, Contenedores, R2),
    append(R2, Tipos, Todas),
    sort(Todas, Unicas),
    Unicas \= [],
    texto_termino(Canonico, Texto),
    texto_lista(Unicas, ListaTexto),
    format(atom(Respuesta), '~w tiene relaciones conocidas o inferidas con: ~w.', [Texto, ListaTexto]).

responder_sinonimos(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    sinonimos_de(Canonico, Sinonimos),
    Sinonimos \= [],
    texto_termino(Canonico, Texto),
    texto_lista(Sinonimos, SinonimosTexto),
    format(atom(Respuesta), 'Estos terminos se pueden usar como sinonimos de ~w: ~w.', [Texto, SinonimosTexto]).

responder_resumen(Termino, Respuesta) :-
    canonico(Termino, Canonico),
    se_conoce_ampliado(Canonico),
    texto_termino(Canonico, Texto),
    resumen_partes(Canonico, Partes),
    Partes \= [],
    atomic_list_concat(Partes, ' ', Resumen),
    format(atom(Respuesta), 'Sobre ~w: ~w', [Texto, Resumen]).






% RELACIONES E INFERENCIAS PUBLICAS

inferir_propiedad(Entidad, Propiedad) :-
    canonico(Entidad, Canonico),
    tiene_propiedad(Canonico, Propiedad).

inferir_tipo(Entidad, Tipo) :-
    canonico(Entidad, Canonico),
    es_un_inferido(Canonico, Tipo).

inferir_relacion(A, B) :-
    canonico(A, CA),
    canonico(B, CB),
    (   mismo_significado(CA, CB)
    ;   es_un_inferido(CA, CB)
    ;   es_un_inferido(CB, CA)
    ;   parte_de(CA, CB)
    ;   parte_de(CB, CA)
    ;   se_relaciona(CA, CB)
    ).

relacion_directa_o_inferida(A, B, Respuesta) :-
    mismo_significado(A, B),
    texto_termino(A, TA),
    texto_termino(B, TB),
    format(atom(Respuesta), '~w y ~w tienen el mismo significado en la base de conocimiento.', [TA, TB]).
relacion_directa_o_inferida(A, B, Respuesta) :-
    es_un_inferido(A, B),
    texto_termino(A, TA),
    texto_termino(B, TB),
    format(atom(Respuesta), 'Por inferencia taxonomica, ~w es un tipo de ~w.', [TA, TB]).
relacion_directa_o_inferida(A, B, Respuesta) :-
    es_un_inferido(B, A),
    texto_termino(B, TB),
    texto_termino(A, TA),
    format(atom(Respuesta), 'Por inferencia taxonomica, ~w es un tipo de ~w.', [TB, TA]).
relacion_directa_o_inferida(A, B, Respuesta) :-
    parte_de(A, B),
    texto_termino(A, TA),
    texto_termino(B, TB),
    format(atom(Respuesta), '~w es parte de ~w.', [TA, TB]).
relacion_directa_o_inferida(A, B, Respuesta) :-
    parte_de(B, A),
    texto_termino(B, TB),
    texto_termino(A, TA),
    format(atom(Respuesta), '~w es parte de ~w.', [TB, TA]).
relacion_directa_o_inferida(A, B, Respuesta) :-
    se_relaciona(A, B),
    texto_termino(A, TA),
    texto_termino(B, TB),
    format(atom(Respuesta), '~w se relaciona logicamente con ~w.', [TA, TB]).






% BUSQUEDAS CON BACKTRACKING

tipos_de(Termino, TiposTexto) :-
    soluciones_unicas(Tipo, es_un_inferido(Termino, Tipo), Tipos),
    maplist(texto_termino, Tipos, TiposTexto).

propiedades_de(Termino, PropiedadesTexto) :-
    soluciones_unicas(Propiedad, tiene_propiedad(Termino, Propiedad), Propiedades),
    maplist(texto_termino, Propiedades, PropiedadesTexto).

relaciones_de(Termino, RelacionesTexto) :-
    soluciones_unicas(Relacion, se_relaciona(Termino, Relacion), Relaciones),
    maplist(texto_termino, Relaciones, RelacionesTexto).

partes_de(Termino, PartesTexto) :-
    soluciones_unicas(Parte, parte_de(Parte, Termino), Partes),
    maplist(texto_termino, Partes, PartesTexto).

contenedores_de(Termino, ContenedoresTexto) :-
    soluciones_unicas(Todo, parte_de(Termino, Todo), Contenedores),
    maplist(texto_termino, Contenedores, ContenedoresTexto).

sinonimos_de(Termino, SinonimosTexto) :-
    soluciones_unicas(S, mismo_significado(S, Termino), Sinonimos),
    excluir_identico(Termino, Sinonimos, Limpios),
    maplist(texto_termino, Limpios, SinonimosTexto).

soluciones_unicas(Variable, Meta, Soluciones) :-
    findall(Variable, Meta, Lista),
    sort(Lista, Soluciones).

excluir_identico(_, [], []).
excluir_identico(Termino, [Termino|Resto], Limpios) :-
    excluir_identico(Termino, Resto, Limpios).
excluir_identico(Termino, [Otro|Resto], [Otro|Limpios]) :-
    Termino \= Otro,
    excluir_identico(Termino, Resto, Limpios).






% RESUMEN GENERAL

resumen_partes(Termino, Partes) :-
    parte_concepto(Termino, P1),
    parte_tipos(Termino, P2),
    parte_propiedades(Termino, P3),
    parte_relaciones(Termino, P4),
    quitar_vacios([P1, P2, P3, P4], Partes).

parte_concepto(Termino, Parte) :-
    concepto(Termino, Concepto),
    format(atom(Parte), 'Es ~w.', [Concepto]),
    !.
parte_concepto(_, '').

parte_tipos(Termino, Parte) :-
    tipos_de(Termino, Tipos),
    Tipos \= [],
    texto_lista(Tipos, Texto),
    format(atom(Parte), 'Se clasifica como: ~w.', [Texto]),
    !.
parte_tipos(_, '').

parte_propiedades(Termino, Parte) :-
    propiedades_de(Termino, Propiedades),
    Propiedades \= [],
    texto_lista(Propiedades, Texto),
    format(atom(Parte), 'Tiene propiedades inferidas: ~w.', [Texto]),
    !.
parte_propiedades(_, '').

parte_relaciones(Termino, Parte) :-
    relaciones_de(Termino, Relaciones),
    Relaciones \= [],
    texto_lista(Relaciones, Texto),
    format(atom(Parte), 'Se relaciona con: ~w.', [Texto]),
    !.
parte_relaciones(_, '').

quitar_vacios([], []).
quitar_vacios([''|Resto], Limpios) :-
    quitar_vacios(Resto, Limpios).
quitar_vacios([X|Resto], [X|Limpios]) :-
    X \= '',
    quitar_vacios(Resto, Limpios).







% APOYO SIN QUERY_PROCESSOR

normalizar_basico(Pregunta, Palabras) :-
    is_list(Pregunta),
    !,
    Palabras = Pregunta.
normalizar_basico(Pregunta, Palabras) :-
    string(Pregunta),
    !,
    string_lower(Pregunta, Min),
    split_string(Min, " ", " ", Trozos),
    maplist(atom_string, Palabras, Trozos).
normalizar_basico(Pregunta, Palabras) :-
    atom(Pregunta),
    atom_string(Pregunta, Texto),
    normalizar_basico(Texto, Palabras).

extraer_terminos_basico(Palabras, Terminos) :-
    findall(Canonico,
        (member(Palabra, Palabras), canonico(Palabra, Canonico), se_conoce_ampliado(Canonico)),
        Encontrados),
    sort(Encontrados, Terminos).

se_conoce_ampliado(T) :- se_conoce(T), !.
se_conoce_ampliado(T) :- parte_de(T, _), !.
se_conoce_ampliado(T) :- parte_de(_, T), !.
se_conoce_ampliado(T) :- sinonimo(T, _), !.
se_conoce_ampliado(T) :- sinonimo(_, T), !.






% FORMATEO DE TEXTO

texto_termino(Termino, Texto) :-
    atomic_list_concat(Partes, '_', Termino),
    atomic_list_concat(Partes, ' ', Texto).

texto_lista([], '').
texto_lista([Unico], Unico) :- !.
texto_lista([Primero, Segundo], Texto) :-
    !,
    format(atom(Texto), '~w y ~w', [Primero, Segundo]).
texto_lista([Primero|Resto], Texto) :-
    texto_lista(Resto, TextoResto),
    format(atom(Texto), '~w, ~w', [Primero, TextoResto]).
