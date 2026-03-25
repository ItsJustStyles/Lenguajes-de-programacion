#include <iostream>
#include <cstring>
#include "ordenes.h"

void agregarOrden(MensajeOrden& msg) {
    Orden* nueva = new Orden();
    nueva->id         = ++restaurante.contadorOrdenes;
    nueva->numeroMesa = msg.numeroMesa;
    nueva->estado     = PENDIENTE;
    nueva->modificada = false;
    nueva->siguiente  = nullptr;

    ItemOrden* item = new ItemOrden();
    item->idProducto = msg.idProducto;
    item->cantidad   = msg.cantidad;
    item->siguiente  = nullptr;
    strncpy(item->nombreProducto,   msg.nombreProducto,   sizeof(item->nombreProducto));
    strncpy(item->especificaciones, msg.especificaciones, sizeof(item->especificaciones));
    nueva->items = item;

    if (restaurante.ordenesHead == nullptr) {
        restaurante.ordenesHead = nueva;
    } else {
        Orden* actual = restaurante.ordenesHead;
        while (actual->siguiente != nullptr) actual = actual->siguiente;
        actual->siguiente = nueva;
    }

    std::cout << "\n[Servidor] Nueva orden almacenada — ID: " << nueva->id
              << " | Mesa: " << nueva->numeroMesa
              << " | Producto: " << msg.nombreProducto << "\n";
}

void mostrarOrdenes(EstadoOrden filtro, bool usarFiltro) {
    Orden* actual = restaurante.ordenesHead;
    bool hayOrdenes = false;

    std::cout << "\n══════════════════════════════════════════\n";
    std::cout << (usarFiltro && filtro == PENDIENTE  ? "  ÓRDENES PENDIENTES\n"  :
                  usarFiltro && filtro == COMPLETADA ? "  ÓRDENES COMPLETADAS\n" :
                  "  TODAS LAS ÓRDENES\n");
    std::cout << "══════════════════════════════════════════\n";

    while (actual != nullptr) {
        if (!usarFiltro || actual->estado == filtro) {
            hayOrdenes = true;
            std::cout << "  ID:         " << actual->id << "\n";
            std::cout << "  Mesa:       " << actual->numeroMesa << "\n";
            std::cout << "  Estado:     " << (actual->estado == PENDIENTE ? "Pendiente" : "Completada") << "\n";
            std::cout << "  Modificada: " << (actual->modificada ? "Si" : "No") << "\n";

            ItemOrden* item = actual->items;
            while (item != nullptr) {
                std::cout << "  Producto:   " << item->nombreProducto
                          << " x" << item->cantidad << "\n";
                if (strlen(item->especificaciones) > 0)
                    std::cout << "  Espec:      " << item->especificaciones << "\n";
                item = item->siguiente;
            }
            std::cout << "──────────────────────────────────────────\n";
        }
        actual = actual->siguiente;
    }

    if (!hayOrdenes) std::cout << "  No hay órdenes.\n";
}

void marcarCompletada() {
    int id;
    std::cout << "ID de la orden a completar: ";
    std::cin >> id;
    std::cin.ignore();

    Orden* actual = restaurante.ordenesHead;
    while (actual != nullptr) {
        if (actual->id == id) {
            actual->estado = COMPLETADA;
            std::cout << "[Servidor] Orden " << id << " marcada como completada.\n";
            return;
        }
        actual = actual->siguiente;
    }
    std::cout << "[Servidor] Orden no encontrada.\n";
}

bool modificarOrden(MensajeOrden& msg) {
    Orden* actual = restaurante.ordenesHead;

    while (actual != nullptr) {
        if (actual->id == msg.idOrden) {
            if (actual->estado == COMPLETADA) {
                std::cout << "[Servidor] Orden " << msg.idOrden << " ya completada, no se puede modificar.\n";
                return false;
            }

            ItemOrden* item = actual->items;
            if (item != nullptr) {
                if (msg.cantidad > 0)
                    item->cantidad = msg.cantidad;
                if (strlen(msg.especificaciones) > 0)
                    strncpy(item->especificaciones, msg.especificaciones, sizeof(item->especificaciones));
                if (strlen(msg.nombreProducto) > 0)
                    strncpy(item->nombreProducto, msg.nombreProducto, sizeof(item->nombreProducto));
            }

            actual->modificada = true;
            std::cout << "[Servidor] Orden " << msg.idOrden << " modificada correctamente.\n";
            return true;
        }
        actual = actual->siguiente;
    }

    std::cout << "[Servidor] Orden " << msg.idOrden << " no encontrada.\n";
    return false;
}