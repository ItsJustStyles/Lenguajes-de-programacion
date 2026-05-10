module Logica where

import Tipos
import Data.List (sortBy, groupBy, maximumBy)
import Data.Ord (comparing, Down(..))
import Data.Time.Clock (utctDay)
import Data.Time.Calendar (toGregorian)
import qualified Data.Map.Strict as Map

-- =====================
-- Utilidad de fechas
-- =====================

mesAnio :: Fecha -> (Integer, Int)
mesAnio t = let (anio, mes, _) = toGregorian (utctDay t) in (anio, mes)

-- =====================
-- Filtrado
-- =====================

filtrarPorTipo :: TipoRegistro -> [RegistroFinanciero] -> [RegistroFinanciero]
filtrarPorTipo t = filter (\r -> tipo r == t)

filtrarPorCategoria :: Categoria -> [RegistroFinanciero] -> [RegistroFinanciero]
filtrarPorCategoria cat = filter (\r -> categoria r == cat)

filtrarPorRangoFecha :: Fecha -> Fecha -> [RegistroFinanciero] -> [RegistroFinanciero]
filtrarPorRangoFecha inicio fin = filter (\r -> fecha r >= inicio && fecha r <= fin)

filtrarPorEtiqueta :: String -> [RegistroFinanciero] -> [RegistroFinanciero]
filtrarPorEtiqueta etiq = filter (\r -> etiq `elem` etiquetas r)

-- =====================
-- Calculos basicos
-- =====================

totalMonto :: [RegistroFinanciero] -> Monto
totalMonto = foldl (\acc r -> acc + monto r) 0.0

totalPorTipo :: TipoRegistro -> [RegistroFinanciero] -> Monto
totalPorTipo t = totalMonto . filtrarPorTipo t

balance :: [RegistroFinanciero] -> Monto
balance registros = totalPorTipo Ingreso registros - totalPorTipo Gasto registros

-- =====================
-- Agrupacion
-- =====================

agruparPorCategoria :: [RegistroFinanciero] -> [(Categoria, Monto)]
agruparPorCategoria registros =
    Map.toList $ foldl (\m r -> Map.insertWith (+) (categoria r) (monto r) m) Map.empty registros

agruparPorMes :: [RegistroFinanciero] -> [((Integer, Int), [RegistroFinanciero])]
agruparPorMes registros =
    let sorted  = sortBy (comparing (mesAnio . fecha)) registros
        grouped = groupBy (\a b -> mesAnio (fecha a) == mesAnio (fecha b)) sorted
    in map (\g -> (mesAnio (fecha (head g)), g)) grouped

-- =====================
-- Flujo de caja mensual
-- =====================

flujoCajaMensual :: [RegistroFinanciero] -> [((Integer, Int), Monto)]
flujoCajaMensual registros =
    map (\(mes, regs) -> (mes, totalPorTipo Ingreso regs - totalPorTipo Gasto regs))
        (agruparPorMes registros)

-- =====================
-- Analisis avanzado
-- =====================

tendenciaGasto :: [RegistroFinanciero] -> [((Integer, Int), Monto)]
tendenciaGasto registros =
    map (\(mes, regs) -> (mes, totalPorTipo Gasto regs)) (agruparPorMes registros)

proyeccionGasto :: [RegistroFinanciero] -> Monto
proyeccionGasto [] = 0.0
proyeccionGasto registros =
    let gastosPorMes = map snd (tendenciaGasto registros)
        n            = fromIntegral (length gastosPorMes)
    in sum gastosPorMes / n

categoriaMayorImpacto :: [RegistroFinanciero] -> Maybe (Categoria, Monto)
categoriaMayorImpacto [] = Nothing
categoriaMayorImpacto registros =
    let grupos = agruparPorCategoria registros
    in if null grupos then Nothing
       else Just (maximumBy (comparing snd) grupos)

-- =====================
-- Simulacion financiera
-- =====================

simularReduccionGastos :: Double -> [RegistroFinanciero] -> [RegistroFinanciero]
simularReduccionGastos porcentaje = map reducir
  where
    factor    = 1.0 - (porcentaje / 100.0)
    reducir r = if tipo r == Gasto then r { monto = monto r * factor } else r

proyeccionAhorro :: Int -> [RegistroFinanciero] -> Monto
proyeccionAhorro meses registros =
    let mesesConDatos     = max 1 (fromIntegral (length (agruparPorMes registros)))
        ahorroMensualProm = totalPorTipo Ahorro registros / mesesConDatos
    in ahorroMensualProm * fromIntegral meses

-- =====================
-- Presupuestos
-- =====================

gastoRealPorCategoria :: Categoria -> [RegistroFinanciero] -> Monto
gastoRealPorCategoria cat = totalMonto . filtrarPorTipo Gasto . filtrarPorCategoria cat

verificarPresupuesto :: Presupuesto -> [RegistroFinanciero] -> Maybe String
verificarPresupuesto p registros =
    let cat  = catPresupuesto p
        lim  = limite p
        real = gastoRealPorCategoria cat registros
    in if real > lim
       then Just $ "ALERTA: La categoria '" ++ cat ++ "' supero el presupuesto. " ++
                   "Gasto real: " ++ show real ++ " | Limite: " ++ show lim
       else Nothing

verificarPresupuestos :: [Presupuesto] -> [RegistroFinanciero] -> [String]
verificarPresupuestos presupuestos registros =
    [msg | Just msg <- map (`verificarPresupuesto` registros) presupuestos]

-- =====================
-- Sistema de reglas
-- =====================

evaluarRegla :: Regla -> [RegistroFinanciero] -> Maybe String
evaluarRegla (ReglaGastoMax cat lim) registros =
    let real = gastoRealPorCategoria cat registros
    in if real > lim
       then Just $ "ALERTA: Gastos en '" ++ cat ++ "' superan el maximo definido (" ++
                   show lim ++ "). Gasto actual: " ++ show real
       else Nothing
evaluarRegla (ReglasAhorroMin minimo) registros =
    let totalAhorro = totalPorTipo Ahorro registros
    in if totalAhorro < minimo
       then Just $ "ADVERTENCIA: El ahorro total (" ++ show totalAhorro ++
                   ") es menor al minimo requerido (" ++ show minimo ++ ")"
       else Nothing

evaluarReglas :: [Regla] -> [RegistroFinanciero] -> [String]
evaluarReglas reglas registros =
    [msg | Just msg <- map (`evaluarRegla` registros) reglas]

-- =====================
-- Reportes
-- =====================

registrosDeMes :: Integer -> Int -> [RegistroFinanciero] -> [RegistroFinanciero]
registrosDeMes anio mes = filter (\r -> mesAnio (fecha r) == (anio, mes))

resumenMensual :: Integer -> Int -> [RegistroFinanciero] -> String
resumenMensual anio mes registros =
    let regs        = registrosDeMes anio mes registros
        ingresos    = totalPorTipo Ingreso regs
        gastos      = totalPorTipo Gasto regs
        ahorros     = totalPorTipo Ahorro regs
        inversiones = totalPorTipo Inversion regs
        bal         = ingresos - gastos
    in unlines
        [ "=== Resumen " ++ show mes ++ "/" ++ show anio ++ " ==="
        , "Ingresos:    " ++ show ingresos
        , "Gastos:      " ++ show gastos
        , "Ahorros:     " ++ show ahorros
        , "Inversiones: " ++ show inversiones
        , "Balance:     " ++ show bal
        ]

comparacionPeriodos :: (Fecha, Fecha) -> (Fecha, Fecha) -> [RegistroFinanciero] -> String
comparacionPeriodos (ini1, fin1) (ini2, fin2) registros =
    let regs1     = filtrarPorRangoFecha ini1 fin1 registros
        regs2     = filtrarPorRangoFecha ini2 fin2 registros
        gastos1   = totalPorTipo Gasto regs1
        gastos2   = totalPorTipo Gasto regs2
        dif       = gastos2 - gastos1
        tendencia
          | dif > 0   = "aumento"
          | dif < 0   = "disminuyo"
          | otherwise = "sin cambios"
    in unlines
        [ "=== Comparacion de periodos ==="
        , "Periodo 1 - Gastos: " ++ show gastos1
        , "Periodo 2 - Gastos: " ++ show gastos2
        , "Diferencia: " ++ show (abs dif) ++ " (" ++ tendencia ++ ")"
        ]

categoriasMayorGasto :: Int -> [RegistroFinanciero] -> [(Categoria, Monto)]
categoriasMayorGasto n registros =
    let grupos    = agruparPorCategoria (filtrarPorTipo Gasto registros)
        ordenados = sortBy (comparing (Down . snd)) grupos
    in take n ordenados
