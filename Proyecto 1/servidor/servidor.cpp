#include <iostream>
#include <cstring>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <pthread.h>
#include "../shared/structs.h"
#include "ordenes.h"
#include "productos.h"
#include "mesas.h"

#define PUERTO 8080
#define MAX_BUFFER 1024

Restaurante restaurante = {0, nullptr, nullptr, 0, 0};
pthread_mutex_t mutex   = PTHREAD_MUTEX_INITIALIZER;

void* hiloReceptor(void* arg) {
    int socketServidor = *(int*)arg;

    while (true) {
        sockaddr_in direccionCliente;
        socklen_t   tamano = sizeof(direccionCliente);

        int socketCliente = accept(socketServidor, (sockaddr*)&direccionCliente, &tamano);
        if (socketCliente < 0) continue;

        MensajeOrden msg;
        memset(&msg, 0, sizeof(msg));
        int bytes = recv(socketCliente, &msg, sizeof(msg), 0);

        if (bytes > 0) {
            pthread_mutex_lock(&mutex);

            if (msg.tipoMensaje == 1) {
                bool exito = modificarOrden(msg);
                if (exito) {
                    const char* respuesta = "Orden modificada correctamente.";
                    send(socketCliente, respuesta, strlen(respuesta), 0);
                } else {
                    const char* respuesta = "Error: orden no encontrada o ya completada.";
                    send(socketCliente, respuesta, strlen(respuesta), 0);
                }
            } else {
                // Nueva orden
                if (!mesaValida(msg.numeroMesa)) {
                    const char* rechazo = "Error: mesa invalida. Orden rechazada.";
                    send(socketCliente, rechazo, strlen(rechazo), 0);
                    std::cout << "[Servidor] Orden rechazada — mesa " << msg.numeroMesa << " no válida.\n";
                } else {
                    agregarOrden(msg);
                    const char* respuesta = "Orden recibida correctamente.";
                    send(socketCliente, respuesta, strlen(respuesta), 0);
                }
            }

            pthread_mutex_unlock(&mutex);
        }

        close(socketCliente);
    }
    return nullptr;
}

void menuServidor() {
    while (true) {
        std::cout << "\n╔══════════════════════════════╗\n";
        std::cout << "║     SERVIDOR RESTAURANTE     ║\n";
        std::cout << "╠══════════════════════════════╣\n";
        std::cout << "║  1. Ver todas las órdenes    ║\n";
        std::cout << "║  2. Ver órdenes pendientes   ║\n";
        std::cout << "║  3. Marcar orden completada  ║\n";
        std::cout << "║  4. Gestionar productos      ║\n";
        std::cout << "║  5. Configurar mesas         ║\n";
        std::cout << "║  6. Salir                    ║\n";
        std::cout << "╚══════════════════════════════╝\n";
        std::cout << "Opcion: ";

        int opcion;
        std::cin >> opcion;
        std::cin.ignore();

        pthread_mutex_lock(&mutex);
        switch (opcion) {
            case 1: mostrarOrdenes(PENDIENTE, false); break;
            case 2: mostrarOrdenes(PENDIENTE, true);  break;
            case 3: marcarCompletada();                break;
            case 4: {
                pthread_mutex_unlock(&mutex);
                std::cout << "\n╔══════════════════════════════╗\n";
                std::cout << "║     GESTIÓN DE PRODUCTOS     ║\n";
                std::cout << "╠══════════════════════════════╣\n";
                std::cout << "║  1. Crear producto           ║\n";
                std::cout << "║  2. Consultar productos      ║\n";
                std::cout << "║  3. Modificar producto       ║\n";
                std::cout << "║  4. Eliminar producto        ║\n";
                std::cout << "║  5. Volver                   ║\n";
                std::cout << "╚══════════════════════════════╝\n";
                std::cout << "Opcion: ";

                int subOpcion;
                std::cin >> subOpcion;
                std::cin.ignore();

                pthread_mutex_lock(&mutex);
                switch (subOpcion) {
                    case 1: crearProducto();      break;
                    case 2: consultarProductos(); break;
                    case 3: modificarProducto();  break;
                    case 4: eliminarProducto();   break;
                    default: std::cout << "Opcion invalida.\n";
                }
                break;
            }
            case 5: configurarMesas(); break;
            case 6:
                std::cout << "[Servidor] Cerrando...\n";
                pthread_mutex_unlock(&mutex);
                exit(0);
            default:
                std::cout << "Opcion invalida.\n";
        }
        pthread_mutex_unlock(&mutex);
    }
}

int main() {
    int socketServidor = socket(AF_INET, SOCK_STREAM, 0);
    if (socketServidor < 0) {
        std::cerr << "[Error] No se pudo crear el socket.\n";
        return 1;
    }

    int opt = 1;
    setsockopt(socketServidor, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    sockaddr_in direccionServidor;
    memset(&direccionServidor, 0, sizeof(direccionServidor));
    direccionServidor.sin_family      = AF_INET;
    direccionServidor.sin_addr.s_addr = INADDR_ANY;
    direccionServidor.sin_port        = htons(PUERTO);

    if (bind(socketServidor, (sockaddr*)&direccionServidor, sizeof(direccionServidor)) < 0) {
        std::cerr << "[Error] Bind fallido.\n";
        return 1;
    }

    if (listen(socketServidor, 5) < 0) {
        std::cerr << "[Error] Listen fallido.\n";
        return 1;
    }

    std::cout << "[Servidor] Escuchando en puerto " << PUERTO << "...\n";

    pthread_t hilo;
    pthread_create(&hilo, nullptr, hiloReceptor, &socketServidor);
    pthread_detach(hilo);

    menuServidor();

    close(socketServidor);
    return 0;
}
