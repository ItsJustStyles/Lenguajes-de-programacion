module Main where

import Tipos
import Validaciones
import Persistencia
import Data.Time.Clock (getCurrentTime)

-- ============================================================
-- Utilidades de reporte para pruebas
-- ============================================================

probar :: String -> Either String RegistroFinanciero -> IO ()
probar nombre resultado = do
    putStrLn $ "\n[" ++ nombre ++ "]"
    case resultado of
        Right r -> putStrLn $ "  OK -> " ++ show r
        Left  e -> putStrLn $ "  ERROR -> " ++ e

-- ============================================================
-- Main
-- ============================================================

main :: IO ()
main = do
    pruebasValidaciones
    pruebasPersistencia

-- ============================================================
-- Fase 2 — Pruebas de Validaciones
-- ============================================================

pruebasValidaciones :: IO ()
pruebasValidaciones = do
    putStrLn "\n========================================="
    putStrLn "=== Pruebas de Validaciones            ==="
    putStrLn "=========================================\n"

    probar "Registro valido (Ingreso)"
        (validarRegistro 50000 "Salario" "2025-05-01" "Pago de quincena" ["fijo"] Ingreso)

    probar "Registro valido (Gasto)"
        (validarRegistro 15000 "Comida" "2025-05-10" "Almuerzo en el TEC" ["variable"] Gasto)

    probar "Registro valido (Ahorro)"
        (validarRegistro 8000 "Fondo emergencia" "2025-05-15" "Ahorro mensual" [] Ahorro)

    probar "Monto negativo"
        (validarRegistro (-500) "Comida" "2025-05-10" "Desc" [] Gasto)

    probar "Monto cero"
        (validarRegistro 0 "Salario" "2025-05-01" "Desc" [] Ingreso)

    probar "Fecha invalida (formato malo)"
        (validarRegistro 1000 "Servicios" "10-05-2025" "Recibo luz" [] Gasto)

    probar "Fecha invalida (texto)"
        (validarRegistro 1000 "Servicios" "hoy" "Recibo agua" [] Gasto)

    probar "Categoria vacia"
        (validarRegistro 5000 "" "2025-06-01" "Sin categoria" [] Ingreso)

    probar "Descripcion vacia"
        (validarRegistro 5000 "Freelance" "2025-06-01" "" [] Ingreso)

    probar "Incoherencia tipo (comida como Ingreso)"
        (validarRegistro 3000 "Comida" "2025-06-05" "Esto no tiene sentido" [] Ingreso)

    probar "Incoherencia tipo (salario como Gasto)"
        (validarRegistro 80000 "Salario" "2025-06-01" "Tampoco tiene sentido" [] Gasto)

    probar "Primer error corta la cadena"
        (validarRegistro (-1) "Cat" "fecha-mala" "Desc" [] Gasto)

-- ============================================================
-- Fase 3 — Pruebas de Persistencia
-- ============================================================

pruebasPersistencia :: IO ()
pruebasPersistencia = do
    putStrLn "\n========================================="
    putStrLn "=== Pruebas de Persistencia            ==="
    putStrLn "=========================================\n"

    ahora <- getCurrentTime

    -- --- RegistroFinanciero ---
    putStrLn "-- RegistroFinanciero --"
    let registros =
            [ Registro 50000.0 "Salario"  ahora "Pago de quincena"   ["fijo"]           Ingreso
            , Registro 15000.0 "Comida"   ahora "Almuerzo en el TEC" ["variable"]       Gasto
            , Registro  8000.0 "Ahorros"  ahora "Fondo emergencia"   ["fijo","mensual"] Ahorro
            , Registro 20000.0 "Acciones" ahora "Compra ETF"         []                 Inversion
            ]
    guardarDatos registros
    recuperados <- cargarDatos
    putStrLn $ "  Guardados : " ++ show (length registros)
    putStrLn $ "  Cargados  : " ++ show (length recuperados)
    putStrLn $ "  Round-trip: " ++ show (registros == recuperados)

    -- --- Presupuesto ---
    putStrLn "\n-- Presupuesto --"
    let presupuestos =
            [ Presupuesto "Comida"    20000.0
            , Presupuesto "Transporte" 8000.0
            , Presupuesto "Ocio"       5000.0
            ]
    guardarPresupuestos presupuestos
    presRecuperados <- cargarPresupuestos
    putStrLn $ "  Guardados : " ++ show (length presupuestos)
    putStrLn $ "  Cargados  : " ++ show (length presRecuperados)
    putStrLn $ "  Round-trip: " ++ show (presupuestos == presRecuperados)

    -- --- Regla ---
    putStrLn "\n-- Regla --"
    let reglas =
            [ ReglaGastoMax "Comida"    20000.0
            , ReglaGastoMax "Ocio"       5000.0
            , ReglasAhorroMin            10000.0
            ]
    guardarReglas reglas
    reglasRecuperadas <- cargarReglas
    putStrLn $ "  Guardados : " ++ show (length reglas)
    putStrLn $ "  Cargados  : " ++ show (length reglasRecuperadas)
    putStrLn $ "  Round-trip: " ++ show (reglas == reglasRecuperadas)

    -- --- Tolerancia a líneas corruptas ---
    putStrLn "\n-- Tolerancia a datos corruptos --"
    guardarLineas archivoRegistros
        [ "50000.0|Salario|2026-05-09T23:58:51.051Z|Pago|fijo|Ingreso"
        , "LINEA_CORRUPTA_SIN_SEPARADORES"
        , "15000.0|Comida|FECHA_MALA|Almuerzo|variable|Gasto"
        , "8000.0|Ahorros|2026-05-09T23:58:51.051Z|Fondo||Ahorro"
        ]
    validos <- cargarDatos
    putStrLn $ "  Lineas escritas : 4"
    putStrLn $ "  Registros validos cargados: " ++ show (length validos)
    putStrLn $ "  (esperado: 2, se saltearon corrupta y fecha mala)"
