module Validaciones where

import Tipos
import Data.Char (toLower)
import Data.List (isInfixOf)
import Data.Time.Format (parseTimeM, defaultTimeLocale)

-- =====================
-- Validaciones individuales
-- =====================

validarMonto :: Double -> Either String Double
validarMonto m
    | m <= 0    = Left $ "El monto debe ser positivo. Recibido: " ++ show m
    | otherwise = Right m

-- Acepta formato "YYYY-MM-DD", retorna UTCTime (Fecha)
validarFecha :: String -> Either String Fecha
validarFecha str =
    case parseTimeM True defaultTimeLocale "%Y-%m-%d" str of
        Just t  -> Right t
        Nothing -> Left $ "Formato de fecha invalido. Use YYYY-MM-DD. Recibido: \"" ++ str ++ "\""

validarCategoria :: Categoria -> Either String Categoria
validarCategoria cat
    | null cat  = Left "La categoria no puede estar vacia"
    | otherwise = Right cat

validarDescripcion :: Descripcion -> Either String Descripcion
validarDescripcion desc
    | null desc = Left "La descripcion no puede estar vacia"
    | otherwise = Right desc

-- Verifica que el tipo de registro sea coherente con la categoria.
-- Usa listas de palabras clave para detectar incoherencias evidentes.
validarCoherenciaTipo :: TipoRegistro -> Categoria -> Either String ()
validarCoherenciaTipo t cat =
    let catLow          = map toLower cat
        palabrasGasto   = ["comida", "alquiler", "renta", "transporte", "entretenimiento",
                           "servicio", "salud", "deuda", "compra", "factura"]
        palabrasIngreso = ["salario", "sueldo", "bonificacion", "freelance", "honorario",
                           "pago recibido", "ingreso", "cobro"]
        esDeGasto   = any (`isInfixOf` catLow) palabrasGasto
        esDeIngreso = any (`isInfixOf` catLow) palabrasIngreso
    in case t of
        Ingreso   -> if esDeGasto
                     then Left $ "Incoherencia: la categoria \"" ++ cat ++
                                 "\" sugiere un Gasto pero el tipo es Ingreso"
                     else Right ()
        Gasto     -> if esDeIngreso
                     then Left $ "Incoherencia: la categoria \"" ++ cat ++
                                 "\" sugiere un Ingreso pero el tipo es Gasto"
                     else Right ()
        -- Ahorro e Inversion no tienen restriccion de categoria
        _         -> Right ()

-- =====================
-- Validacion completa
-- =====================

-- Valida todos los campos y construye el RegistroFinanciero.
-- Usa la monada Either: el primer fallo corta la cadena y retorna Left.
validarRegistro
    :: Double
    -> Categoria
    -> Fecha
    -> Descripcion
    -> [Etiquetas]
    -> TipoRegistro
    -> Either String RegistroFinanciero
validarRegistro m cat f desc etiq t = do
    montoValido <- validarMonto m
    catValida   <- validarCategoria cat
    descValida  <- validarDescripcion desc
    _           <- validarCoherenciaTipo t cat
    Right $ Registro
        { monto       = montoValido
        , categoria   = catValida
        , fecha       = f
        , descripcion = descValida
        , etiquetas   = etiq
        , tipo        = t
        }
