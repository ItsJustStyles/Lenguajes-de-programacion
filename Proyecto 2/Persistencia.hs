module Persistencia where

import Tipos
import Data.List (intercalate)
import Data.Time.Format (formatTime, parseTimeM, defaultTimeLocale)
import System.Directory (doesFileExist, createDirectoryIfMissing)
import System.FilePath (takeDirectory)

-- ============================================================
-- Rutas de archivos
-- ============================================================

archivoRegistros :: FilePath
archivoRegistros = "Reportes/finanzas.csv"

archivoPresupuestos :: FilePath
archivoPresupuestos = "Reportes/presupuestos.csv"

archivoReglas :: FilePath
archivoReglas = "Reportes/reglas.csv"

-- ============================================================
-- Formato de fecha ISO 8601 con microsegundos
-- ============================================================

fmtFecha :: String
fmtFecha = "%Y-%m-%dT%H:%M:%S%QZ"

serializarFecha :: Fecha -> String
serializarFecha = formatTime defaultTimeLocale fmtFecha

deserializarFecha :: String -> Maybe Fecha
deserializarFecha = parseTimeM True defaultTimeLocale fmtFecha

-- ============================================================
-- Serialización de RegistroFinanciero  (separador '|')
-- Etiquetas separadas por ';' dentro de su campo
-- ============================================================

registroALinea :: RegistroFinanciero -> String
registroALinea r = intercalate "|"
    [ show (monto r)
    , categoria r
    , serializarFecha (fecha r)
    , descripcion r
    , intercalate ";" (etiquetas r)
    , show (tipo r)
    ]

lineaARegistro :: String -> Maybe RegistroFinanciero
lineaARegistro linea =
    case splitOn '|' linea of
        [m, cat, f, desc, etqs, t] ->
            case (reads m, deserializarFecha f, reads t) of
                ([(m', _)], Just f', [(t', _)]) ->
                    Just Registro
                        { monto       = m'
                        , categoria   = cat
                        , fecha       = f'
                        , descripcion = desc
                        , etiquetas   = if null etqs then [] else splitOn ';' etqs
                        , tipo        = t'
                        }
                _ -> Nothing
        _ -> Nothing

-- ============================================================
-- Serialización de Presupuesto
-- ============================================================

presupuestoALinea :: Presupuesto -> String
presupuestoALinea p = catPresupuesto p ++ "|" ++ show (limite p)

lineaAPresupuesto :: String -> Maybe Presupuesto
lineaAPresupuesto linea =
    case splitOn '|' linea of
        [cat, lim] ->
            case reads lim of
                [(lim', _)] -> Just Presupuesto { catPresupuesto = cat, limite = lim' }
                _           -> Nothing
        _ -> Nothing

-- ============================================================
-- Serialización de Regla
-- Prefijo de constructor como primer campo para identificar el tipo
-- ============================================================

reglaALinea :: Regla -> String
reglaALinea (ReglaGastoMax cat m) = intercalate "|" ["GastoMax", cat, show m]
reglaALinea (ReglasAhorroMin m)   = "AhorroMin|" ++ show m

lineaARegla :: String -> Maybe Regla
lineaARegla linea =
    case splitOn '|' linea of
        ["GastoMax", cat, m] ->
            case reads m of
                [(m', _)] -> Just (ReglaGastoMax cat m')
                _         -> Nothing
        ["AhorroMin", m] ->
            case reads m of
                [(m', _)] -> Just (ReglasAhorroMin m')
                _         -> Nothing
        _ -> Nothing

-- ============================================================
-- Utilidad: split por un carácter delimitador
-- ============================================================

splitOn :: Char -> String -> [String]
splitOn _ "" = [""]
splitOn delim str = foldr f [""] str
  where
    f c (x:xs)
        | c == delim = "" : x : xs
        | otherwise  = (c : x) : xs
    f _ [] = []

-- ============================================================
-- IO interno genérico
-- ============================================================

guardarLineas :: FilePath -> [String] -> IO ()
guardarLineas ruta lineas = do
    createDirectoryIfMissing True (takeDirectory ruta)
    writeFile ruta (unlines lineas)

cargarLineas :: FilePath -> IO [String]
cargarLineas ruta = do
    existe <- doesFileExist ruta
    if existe
        then filter (not . null) . lines <$> readFile ruta
        else return []

-- ============================================================
-- API pública — RegistroFinanciero
-- ============================================================

guardarDatos :: [RegistroFinanciero] -> IO ()
guardarDatos rs = guardarLineas archivoRegistros (map registroALinea rs)

cargarDatos :: IO [RegistroFinanciero]
cargarDatos = do
    ls <- cargarLineas archivoRegistros
    return [r | Just r <- map lineaARegistro ls]

-- ============================================================
-- API pública — Presupuesto
-- ============================================================

guardarPresupuestos :: [Presupuesto] -> IO ()
guardarPresupuestos ps = guardarLineas archivoPresupuestos (map presupuestoALinea ps)

cargarPresupuestos :: IO [Presupuesto]
cargarPresupuestos = do
    ls <- cargarLineas archivoPresupuestos
    return [p | Just p <- map lineaAPresupuesto ls]

-- ============================================================
-- API pública — Regla
-- ============================================================

guardarReglas :: [Regla] -> IO ()
guardarReglas rs = guardarLineas archivoReglas (map reglaALinea rs)

cargarReglas :: IO [Regla]
cargarReglas = do
    ls <- cargarLineas archivoReglas
    return [r | Just r <- map lineaARegla ls]
