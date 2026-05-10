module Persistencia where

import Tipos
import System.IO

import System.Directory (doesFileExist, createDirectoryIfMissing)
import System.FilePath (takeDirectory)

-- Ruta del archivo:
nombreArchivo :: FilePath
nombreArchivo = "Reportes/finanzas.txt"

-- Guardas los registros:
guardarDatos :: [RegistroFinanciero] -> IO ()
guardarDatos registros = do
    createDirectoryIfMissing True (takeDirectory nombreArchivo)
    writeFile nombreArchivo (show registros)

-- Reconstruir la información de los reportes generados:
cargarDatos :: IO [RegistroFinanciero] 
cargarDatos = do
    existe <- doesFileExist nombreArchivo
    if existe
        then do
            contenido <- readFile nombreArchivo
            return (read contenido)
    else return []