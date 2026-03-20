#pragma once

// ─── Producto del menú ───────────────────────────────────────────
struct Producto {
    int       id;
    char      nombre[50];
    float     precio;
    char      descripcion[255];
    Producto* siguiente;
};

// ─── Ítem dentro de una orden ────────────────────────────────────
struct ItemOrden {
    int        idProducto;
    char       nombreProducto[50];
    int        cantidad;
    char       especificaciones[255];
    ItemOrden* siguiente;
};

// ─── Orden completa ──────────────────────────────────────────────
enum EstadoOrden { PENDIENTE, COMPLETADA };

struct Orden {
    int         id;
    int         numeroMesa;
    EstadoOrden estado;
    bool        modificada;
    ItemOrden*  items;
    Orden*      siguiente;
};

// ─── Configuración del restaurante ───────────────────────────────
struct Restaurante {
    int       totalMesas;
    Producto* menuHead;
    Orden*    ordenesHead;
    int       contadorOrdenes;
    int       contadorProductos;
};

// ─── Mensaje serializable para enviar por socket ─────────────────
struct MensajeOrden {
    int  tipoMensaje; // 0=nueva orden, 1=modificar, 2=cancelar
    int  idOrden;     // ncesario para modificar
    int  numeroMesa;
    int  idProducto;
    char nombreProducto[50];
    int  cantidad;
    char especificaciones[255];
};