#include <iostream>
#include "mesas.h"

bool mesaValida(int numeroMesa) {
    return restaurante.totalMesas > 0 && numeroMesa >= 1 && numeroMesa <= restaurante.totalMesas;
}

void configurarMesas() {
    std::cout << "Número de mesas actual: " << restaurante.totalMesas << "\n";
    std::cout << "Nuevo número de mesas: ";
    std::cin >> restaurante.totalMesas;
    std::cin.ignore();
    std::cout << "[Servidor] Número de mesas actualizado a: " << restaurante.totalMesas << "\n";
}
