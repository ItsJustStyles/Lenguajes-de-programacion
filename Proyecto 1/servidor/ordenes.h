#pragma once
#include "../shared/structs.h"

extern Restaurante restaurante;

void agregarOrden(MensajeOrden& msg);
void mostrarOrdenes(EstadoOrden filtro, bool usarFiltro);
void marcarCompletada();
bool modificarOrden(MensajeOrden& msg);