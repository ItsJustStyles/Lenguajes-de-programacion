#include <iostream>
#include <cstring>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include "../shared/structs.h"

#define MAX_BUFFER 1024
#define PUERTO 8080
#define IP_SERVIDOR "localhost"

MensajeOrden pedirOrden() {
    MensajeOrden orden;
    memset(&orden, 0, sizeof(orden));

    orden.tipoMensaje = 0;

    std::cout << "\n=== Nueva Orden ===\n";

    std::cout << "Numero de mesa: ";
    std::cin >> orden.numeroMesa;
    std::cin.ignore();

    std::cout << "Nombre del producto: ";
    std::cin.getline(orden.nombreProducto, sizeof(orden.nombreProducto));

    std::cout << "Cantidad: ";
    std::cin >> orden.cantidad;
    std::cin.ignore();

    std::cout << "Especificaciones (Enter para omitir): ";
    std::cin.getline(orden.especificaciones, sizeof(orden.especificaciones));

    return orden;
}

int conectarServidor() {
    int socketCliente = socket(AF_INET, SOCK_STREAM, 0);
    if (socketCliente < 0) {
        std::cerr << "[Error] No se pudo crear el socket\n";
        return -1;
    }

    sockaddr_in direccionServidor;
    memset(&direccionServidor, 0, sizeof(direccionServidor));
    direccionServidor.sin_family = AF_INET;
    direccionServidor.sin_port = htons(PUERTO);
    inet_pton(AF_INET, IP_SERVIDOR, &direccionServidor.sin_addr);

    if (connect(socketCliente, (sockaddr*)&direccionServidor, sizeof(direccionServidor)) < 0) {
        std::cerr << "[Error] No se pudo conectar al servidor\n";
        close(socketCliente);
        return -1;
    }

    return socketCliente;
}

void enviarOrden(int socketCliente, MensajeOrden& orden) {
    send(socketCliente, &orden, sizeof(orden), 0);

    std::cout << "\n[Cliente] Orden enviada:\n";
    std::cout << "Mesa: " << orden.numeroMesa << "\n";
    std::cout << "Producto: " << orden.nombreProducto << "\n";
    std::cout << "Cantidad: " << orden.cantidad << "\n";
    std::cout << "  Especificaciones: " << orden.especificaciones << "\n";

    char buffer[MAX_BUFFER] = {0};
    int bytesRecibidos = recv(socketCliente, buffer, MAX_BUFFER, 0);

    if (bytesRecibidos > 0) {
        std::cout << "[Cliente] Servidor: " << buffer << "\n";
    }
}

void modificarOrden() {
    int id;
    std::cout << "\n=== Modificar Orden ===\n";
    std::cout << "ID de la orden a modificar: ";
    std::cin >> id;
    std::cin.ignore();

    MensajeOrden orden;
    memset(&orden, 0, sizeof(orden));
    orden.tipoMensaje = 1;
    orden.idOrden = id;

    std::cout << "Nuevo producto (Enter para mantener): ";
    std::cin.getline(orden.nombreProducto, sizeof(orden.nombreProducto));

    std::cout << "Nueva cantidad (0 para mantener): ";
    std::cin >> orden.cantidad;
    std::cin.ignore();

    std::cout << "Nuevas especificaciones (Enter para mantener): ";
    std::cin.getline(orden.especificaciones, sizeof(orden.especificaciones));

    int socketCliente = conectarServidor();
    if (socketCliente < 0) return;

    enviarOrden(socketCliente, orden);
    close(socketCliente);
}

int main() {
    while (true) {
        std::cout << "\n=== SISTEMA MESERO ===\n";
        std::cout << "1. Registrar orden\n";
        std::cout << "2. Modificar orden\n";
        std::cout << "3. Salir\n";
        std::cout << "Opcion: ";

        int opcion;
        std::cin >> opcion;
        std::cin.ignore();

        switch (opcion) {
            case 1: {
                MensajeOrden orden = pedirOrden();
                int socketCliente = conectarServidor();
                if (socketCliente >= 0) {
                    enviarOrden(socketCliente, orden);
                    close(socketCliente);
                }
                break;
            }
            case 2:
                modificarOrden();
                break;
            case 3:
                std::cout << "[Cliente] Cerrando...\n";
                return 0;
            default:
                std::cout << "[Cliente] Opcion invalida.\n";
        }
    }

    return 0;
}
