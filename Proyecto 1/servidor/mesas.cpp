#include <iostream>
#include "mesas.h"

void configurarMesas() {
    std::cout << "Nuevo numero de mesas: ";
    std::cin >> restaurante.totalMesas;
    std::cin.ignore();
    std::cout << "[Servidor] Mesas configuradas correctamente\n";
}
