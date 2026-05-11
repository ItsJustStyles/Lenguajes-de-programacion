module Main where

import Tipos
import Validaciones

-- =====================
-- Pruebas de Validaciones.hs
-- =====================

probar :: String -> Either String RegistroFinanciero -> IO ()
probar nombre resultado = do
    putStrLn $ "\n[" ++ nombre ++ "]"
    case resultado of
        Right r -> putStrLn $ "  OK -> " ++ show r
        Left  e -> putStrLn $ "  ERROR -> " ++ e

main :: IO ()
main = do
    putStrLn "=== Pruebas de validaciones ==="

    -- Caso valido: ingreso normal
    probar "Registro valido (Ingreso)"
        (validarRegistro 50000 "Salario" "2025-05-01" "Pago de quincena" ["fijo"] Ingreso)

    -- Caso valido: gasto
    probar "Registro valido (Gasto)"
        (validarRegistro 15000 "Comida" "2025-05-10" "Almuerzo en el TEC" ["variable"] Gasto)

    -- Caso valido: ahorro
    probar "Registro valido (Ahorro)"
        (validarRegistro 8000 "Fondo emergencia" "2025-05-15" "Ahorro mensual" [] Ahorro)

    -- Error: monto negativo
    probar "Monto negativo"
        (validarRegistro (-500) "Comida" "2025-05-10" "Desc" [] Gasto)

    -- Error: monto cero
    probar "Monto cero"
        (validarRegistro 0 "Salario" "2025-05-01" "Desc" [] Ingreso)

    -- Error: formato de fecha incorrecto
    probar "Fecha invalida (formato malo)"
        (validarRegistro 1000 "Servicios" "10-05-2025" "Recibo luz" [] Gasto)

    -- Error: fecha con texto basura
    probar "Fecha invalida (texto)"
        (validarRegistro 1000 "Servicios" "hoy" "Recibo agua" [] Gasto)

    -- Error: categoria vacia
    probar "Categoria vacia"
        (validarRegistro 5000 "" "2025-06-01" "Sin categoria" [] Ingreso)

    -- Error: descripcion vacia
    probar "Descripcion vacia"
        (validarRegistro 5000 "Freelance" "2025-06-01" "" [] Ingreso)

    -- Error: incoherencia tipo - categoria sugiere Gasto pero tipo es Ingreso
    probar "Incoherencia tipo (comida como Ingreso)"
        (validarRegistro 3000 "Comida" "2025-06-05" "Esto no tiene sentido" [] Ingreso)

    -- Error: incoherencia tipo - categoria sugiere Ingreso pero tipo es Gasto
    probar "Incoherencia tipo (salario como Gasto)"
        (validarRegistro 80000 "Salario" "2025-06-01" "Tampoco tiene sentido" [] Gasto)

    -- Verificar que el primer error corta la cadena (monto malo + fecha mala -> solo reporta monto)
    probar "Primer error corta la cadena"
        (validarRegistro (-1) "Cat" "fecha-mala" "Desc" [] Gasto)
