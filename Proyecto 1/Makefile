CXX   = g++
FLAGS = -Wall -std=c++17

all: servidor cliente

servidor: servidor/servidor.cpp servidor/ordenes.cpp servidor/productos.cpp servidor/mesas.cpp shared/structs.h
	$(CXX) $(FLAGS) servidor/servidor.cpp servidor/ordenes.cpp servidor/productos.cpp servidor/mesas.cpp -o servidor/servidor -lpthread

cliente: cliente/cliente.cpp shared/structs.h
	$(CXX) $(FLAGS) cliente/cliente.cpp -o cliente/cliente

clean:
	rm -f servidor/servidor cliente/cliente
