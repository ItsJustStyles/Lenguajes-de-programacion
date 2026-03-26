CXX   = g++
FLAGS = -Wall -std=c++17
LIBS  = -lpthread

.PHONY: all clean

all: servidor/servidor cliente/cliente

servidor/servidor: servidor/servidor.cpp servidor/ordenes.cpp servidor/productos.cpp servidor/mesas.cpp shared/structs.h
	$(CXX) $(FLAGS) servidor/servidor.cpp servidor/ordenes.cpp servidor/productos.cpp servidor/mesas.cpp -o servidor/servidor $(LIBS)

cliente/cliente: cliente/cliente.cpp shared/structs.h
	$(CXX) $(FLAGS) cliente/cliente.cpp -o cliente/cliente

clean:
	rm -f servidor/servidor cliente/cliente