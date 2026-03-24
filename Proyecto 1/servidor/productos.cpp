#include <iostream>
#include <cstring>
#include "productos.h"

void crearProducto() {
    Producto* nuevo = new Producto();
    nuevo->siguiente = nullptr;
    nuevo->id = ++restaurante.contadorProductos;

    std::cout << "Nombre del producto: ";
    std::cin.getline(nuevo->nombre, sizeof(nuevo->nombre));

    std::cout << "Precio: ";
    std::cin >> nuevo->precio;
    std::cin.ignore();

    std::cout << "Descripcion: ";
    std::cin.getline(nuevo->descripcion, sizeof(nuevo->descripcion));

    if (restaurante.menuHead == nullptr) {
        restaurante.menuHead = nuevo;
    } else {
        Producto* actual = restaurante.menuHead;
        while (actual->siguiente != nullptr) actual = actual->siguiente;
        actual->siguiente = nuevo;
    }

    std::cout << "[Servidor] Producto creado con ID: " << nuevo->id << "\n";
}

void consultarProductos() {
    std::cout << "\n══════════════════════════════════════════\n";
    std::cout << "  MENÚ DE PRODUCTOS\n";
    std::cout << "══════════════════════════════════════════\n";

    Producto* actual = restaurante.menuHead;
    if (actual == nullptr) {
        std::cout << "  No hay productos registrados.\n";
        return;
    }

    while (actual != nullptr) {
        std::cout << "  ID:          " << actual->id << "\n";
        std::cout << "  Nombre:      " << actual->nombre << "\n";
        std::cout << "  Precio:      " << actual->precio << "\n";
        std::cout << "  Descripcion: " << actual->descripcion << "\n";
        std::cout << "──────────────────────────────────────────\n";
        actual = actual->siguiente;
    }
}

void modificarProducto() {
    consultarProductos();

    int id;
    std::cout << "ID del producto a modificar: ";
    std::cin >> id;
    std::cin.ignore();

    Producto* actual = restaurante.menuHead;
    while (actual != nullptr) {
        if (actual->id == id) {
            char temp[100];

            std::cout << "Nuevo nombre (Enter para mantener): ";
            std::cin.getline(temp, sizeof(temp));
            if (strlen(temp) > 0) strncpy(actual->nombre, temp, sizeof(actual->nombre));

            std::cout << "Nuevo precio (0 para mantener): ";
            float precio;
            std::cin >> precio;
            std::cin.ignore();
            if (precio > 0) actual->precio = precio;

            std::cout << "Nueva descripcion (Enter para mantener): ";
            std::cin.getline(temp, sizeof(temp));
            if (strlen(temp) > 0) strncpy(actual->descripcion, temp, sizeof(actual->descripcion));

            std::cout << "[Servidor] Producto modificado.\n";
            return;
        }
        actual = actual->siguiente;
    }
    std::cout << "[Servidor] Producto no encontrado.\n";
}

void eliminarProducto() {
    consultarProductos();

    int id;
    std::cout << "ID del producto a eliminar: ";
    std::cin >> id;
    std::cin.ignore();

    Producto* actual  = restaurante.menuHead;
    Producto* anterior = nullptr;

    while (actual != nullptr) {
        if (actual->id == id) {
            if (anterior == nullptr) {
                restaurante.menuHead = actual->siguiente;
            } else {
                anterior->siguiente = actual->siguiente;
            }
            delete actual;
            std::cout << "[Servidor] Producto eliminado.\n";
            return;
        }
        anterior = actual;
        actual   = actual->siguiente;
    }
    std::cout << "[Servidor] Producto no encontrado.\n";
}