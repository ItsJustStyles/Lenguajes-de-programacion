module Main where

import Interfaz (iniciarInterfaz)
import Persistencia
import System.IO (BufferMode(NoBuffering), hSetBuffering, stdout)

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering

    registros <- cargarDatos
    presupuestos <- cargarPresupuestos
    reglas <- cargarReglas

    putStrLn "------------------------------------"
    putStrLn " Sistema de Finanzas Personales "
    putStrLn "------------------------------------"
    putStrLn $ "Registros cargados:    " ++ show (length registros)
    putStrLn $ "Presupuestos cargados: " ++ show (length presupuestos)
    putStrLn $ "Reglas cargadas:       " ++ show (length reglas)

    (registrosFinales, presupuestosFinales, reglasFinales) <-
        iniciarInterfaz registros presupuestos reglas

    guardarDatos registrosFinales
    guardarPresupuestos presupuestosFinales
    guardarReglas reglasFinales

    putStrLn "\n[OK] Datos guardados correctamente :D"
    putStrLn "El programa ha finalizado"
