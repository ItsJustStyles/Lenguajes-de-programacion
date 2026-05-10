-- Este codigo solo es una prueba xd, para ver si los modulo de Pesistencia.hs y Tipos.hs funcionan correctamente:

module Main where

import Tipos
import Persistencia

import Data.Time.Clock (getCurrentTime)
import Data.Graph (dff)

main :: IO ()
main = do
    ahora <- getCurrentTime

    let registro1 = Registro 50000 "Salario" ahora "Pago de quincena" ["fijo"] Ingreso
    let registro2 = Registro 15000 "Comida" ahora "Almuerzo en el TEC" ["variable"] Gasto
    let listaPrueba = [registro1, registro2]

    putStrLn "Guardando datos de prueba..."
    guardarDatos listaPrueba
    
    putStrLn "Datos guardados. Ahora intentando cargar..."

    datosCargados <- cargarDatos
    
    putStrLn "Datos recuperados del archivo:"
    print datosCargados
    
    let soloGastos = filter (\r -> tipo r == Gasto) datosCargados
    putStrLn $ "Total de registros de tipo Gasto: " ++ show (length soloGastos)