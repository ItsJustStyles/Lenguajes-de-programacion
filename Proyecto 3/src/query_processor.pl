:- set_prolog_flag(encoding, utf8).
:- ensure_loaded('knowledge_base.pl').





% PROCESAMIENTO PRINCIPAL

procesar_pregunta(Pregunta, Intencion, Terminos) :-
    normalizar_pregunta(Pregunta, Palabras),
    detectar_intencion(Palabras, Intencion),
    detectar_terminos(Palabras, TerminosDetectados),
    extraer_palabras_clave(Palabras, Claves),
    terminos_desde_claves(Claves, TerminosClaves),
    append(TerminosDetectados, TerminosClaves, Todos),
    sort(Todos, Terminos).






% NORMALIZACION DE TEXTO

normalizar_pregunta(Pregunta, Palabras) :-
    is_list(Pregunta),
    !,
    normalizar_lista(Pregunta, Palabras).
normalizar_pregunta(Pregunta, Palabras) :-
    string(Pregunta),
    !,
    string_lower(Pregunta, Min),
    split_string(Min, " ", " ", Trozos),
    normalizar_lista(Trozos, Palabras).
normalizar_pregunta(Pregunta, Palabras) :-
    atom(Pregunta),
    atom_string(Pregunta, Texto),
    normalizar_pregunta(Texto, Palabras).

normalizar_lista([], []).
normalizar_lista([Token|Resto], Palabras) :-
    limpiar_token(Token, Limpio),
    normalizar_lista(Resto, PalabrasResto),
    agregar_si_no_vacio(Limpio, PalabrasResto, Palabras).


agregar_si_no_vacio('', Lista, Lista) :- !.
agregar_si_no_vacio(Token, Lista, [Token|Lista]).


limpiar_token(Token, AtomLimpio) :-
    convertir_a_string(Token, Texto),
    string_lower(Texto, Min),
    string_chars(Min, Caracteres),
    normalizar_caracteres(Caracteres, Normalizados),
    incluir_validos(Normalizados, Limpios),
    string_chars(TextoLimpio, Limpios),
    convertir_limpio_a_atomo(TextoLimpio, AtomLimpio).

convertir_a_string(Token, Texto) :- string(Token), !, Texto = Token.
convertir_a_string(Token, Texto) :- atom(Token), !, atom_string(Token, Texto).
convertir_a_string(Token, Texto) :- number(Token), !, number_string(Token, Texto).

convertir_limpio_a_atomo('', '') :- !.
convertir_limpio_a_atomo(Texto, Atomo) :- atom_string(Atomo, Texto).

normalizar_caracteres([], []).
normalizar_caracteres([C|Resto], [N|Normalizados]) :-
    normalizar_caracter(C, N),
    normalizar_caracteres(Resto, Normalizados).

normalizar_caracter('á', 'a') :- !.
normalizar_caracter('é', 'e') :- !.
normalizar_caracter('í', 'i') :- !.
normalizar_caracter('ó', 'o') :- !.
normalizar_caracter('ú', 'u') :- !.
normalizar_caracter('ü', 'u') :- !.
normalizar_caracter(C, C).

incluir_validos([], []).
incluir_validos([C|Resto], [C|Limpios]) :-
    caracter_valido(C),
    !,
    incluir_validos(Resto, Limpios).
incluir_validos([_|Resto], Limpios) :-
    incluir_validos(Resto, Limpios).

caracter_valido(C) :- char_type(C, alnum), !.
caracter_valido('_').





% PREDICADOS AUXILIARES

contiene_palabra(Texto, Palabra) :-
    normalizar_pregunta(Texto, Palabras),
    limpiar_token(Palabra, PalabraLimpia),
    member(PalabraLimpia, Palabras).

extraer_palabras_clave(Pregunta, PalabrasClave) :-
    normalizar_pregunta(Pregunta, Palabras),
    remover_palabras_vacias(Palabras, SinVacias),
    normalizar_sinonimos_lista(SinVacias, Normalizadas),
    sort(Normalizadas, PalabrasClave).

buscar_por_sinonimos(Palabra, Alternativas) :-
    limpiar_token(Palabra, Limpia),
    canonico(Limpia, Canonico),
    findall(Alt, mismo_significado(Alt, Canonico), Lista),
    sort([Canonico|Lista], Alternativas).






% DETECCION DE INTENCIONES

detectar_intencion(Palabras, saludo) :-
    member(P, Palabras),
    palabra_saludo(P),
    !.
detectar_intencion(Palabras, definicion) :-
    member(P, Palabras),
    palabra_definicion(P),
    !.
detectar_intencion(Palabras, utilidad) :-
    member(P, Palabras),
    palabra_utilidad(P),
    !.
detectar_intencion(Palabras, propiedades) :-
    member(P, Palabras),
    palabra_propiedad(P),
    !.
detectar_intencion(Palabras, sinonimo) :-
    member(P, Palabras),
    palabra_sinonimo(P),
    !.
detectar_intencion(Palabras, relacion) :-
    member(P, Palabras),
    palabra_relacion(P),
    !.
detectar_intencion(Palabras, consulta_tipo) :-
    patron_que_es(Palabras),
    !.
detectar_intencion(_, consulta_general).

palabra_saludo(hola).
palabra_saludo(buenas).
palabra_saludo(saludos).

palabra_definicion(defina).
palabra_definicion(define).
palabra_definicion(definir).
palabra_definicion(definicion).
palabra_definicion(explique).
palabra_definicion(explica).
palabra_definicion(explicame).
palabra_definicion(describa).
palabra_definicion(describe).

palabra_utilidad(sirve).
palabra_utilidad(servir).
palabra_utilidad(utilidad).
palabra_utilidad(usa).
palabra_utilidad(uso).
palabra_utilidad(usos).
palabra_utilidad(funciona).

palabra_propiedad(propiedad).
palabra_propiedad(propiedades).
palabra_propiedad(caracteristica).
palabra_propiedad(caracteristicas).
palabra_propiedad(tiene).
palabra_propiedad(tienen).

palabra_sinonimo(sinonimo).
palabra_sinonimo(sinonimos).
palabra_sinonimo(significa).
palabra_sinonimo(equivale).
palabra_sinonimo(equivalente).

palabra_relacion(relacion).
palabra_relacion(relaciona).
palabra_relacion(relacionado).
palabra_relacion(parte).
palabra_relacion(tipo).
palabra_relacion(clase).
palabra_relacion(pertenece).

patron_que_es([que, es|_]).
patron_que_es([que, son|_]).
patron_que_es(Palabras) :- member(que, Palabras), member(es, Palabras).
patron_que_es(Palabras) :- member(que, Palabras), member(son, Palabras).





% DETECCION DE TERMINOS

detectar_terminos(Palabras, TerminosCanonicos) :-
    findall(Canonico,
        (termino_base(Termino), termino_mencionado(Palabras, Termino), canonico(Termino, Canonico)),
        Encontrados),
    sort(Encontrados, TerminosCanonicos).

terminos_desde_claves([], []).
terminos_desde_claves([Clave|Resto], Terminos) :-
    canonico(Clave, Canonico),
    se_conoce_ampliado_qp(Canonico),
    !,
    terminos_desde_claves(Resto, TerminosResto),
    Terminos = [Canonico|TerminosResto].
terminos_desde_claves([_|Resto], Terminos) :-
    terminos_desde_claves(Resto, Terminos).

termino_mencionado(Palabras, Termino) :-
    termino_a_palabras(Termino, Partes),
    contiene_sublista(Palabras, Partes).

termino_a_palabras(Termino, Palabras) :-
    atomic_list_concat(Partes, '_', Termino),
    normalizar_lista(Partes, Palabras).

contiene_sublista(Lista, Sublista) :-
    Sublista \= [],
    append(_, Resto, Lista),
    append(Sublista, _, Resto),
    !.

termino_base(T) :- concepto(T, _).
termino_base(T) :- definicion(T, _).
termino_base(T) :- es_un(T, _).
termino_base(T) :- es_un(_, T).
termino_base(T) :- parte_de(T, _).
termino_base(T) :- parte_de(_, T).
termino_base(T) :- propiedad(T, _).
termino_base(T) :- propiedad(_, T).
termino_base(T) :- relacionado(T, _).
termino_base(T) :- relacionado(_, T).
termino_base(T) :- sinonimo(T, _).
termino_base(T) :- sinonimo(_, T).

se_conoce_ampliado_qp(T) :- se_conoce(T), !.
se_conoce_ampliado_qp(T) :- termino_base(T), !.





% PALABRAS CLAVE Y SINONIMOS

remover_palabras_vacias([], []).
remover_palabras_vacias([P|Resto], Limpias) :-
    palabra_vacia(P),
    !,
    remover_palabras_vacias(Resto, Limpias).
remover_palabras_vacias([P|Resto], [P|Limpias]) :-
    remover_palabras_vacias(Resto, Limpias).

palabra_vacia(que).
palabra_vacia(es).
palabra_vacia(son).
palabra_vacia(un).
palabra_vacia(una).
palabra_vacia(el).
palabra_vacia(la).
palabra_vacia(los).
palabra_vacia(las).
palabra_vacia(lo).
palabra_vacia(de).
palabra_vacia(del).
palabra_vacia(al).
palabra_vacia(para).
palabra_vacia(por).
palabra_vacia(con).
palabra_vacia(en).
palabra_vacia(y).
palabra_vacia(o).
palabra_vacia(me).
palabra_vacia(puedes).
palabra_vacia(puede).
palabra_vacia(podrias).
palabra_vacia(dime).
palabra_vacia(cual).
palabra_vacia(cuales).
palabra_vacia(cuando).
palabra_vacia(como).
palabra_vacia(esto).
palabra_vacia(eso).

normalizar_sinonimos_lista([], []).
normalizar_sinonimos_lista([P|Resto], [Canonico|Normalizadas]) :-
    canonico(P, Canonico),
    normalizar_sinonimos_lista(Resto, Normalizadas).
