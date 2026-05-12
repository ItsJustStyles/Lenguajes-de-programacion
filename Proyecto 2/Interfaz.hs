module Interfaz
    ( iniciarInterfaz
    ) where

import Tipos
import Logica
import Validaciones

import Data.Char (isSpace, toLower)
import Data.List (intercalate)
import Data.Time.Format (formatTime, defaultTimeLocale)
import System.Directory (createDirectoryIfMissing)
import Text.Printf (printf)
import Text.Read (readMaybe)



separador :: IO ()
separador = putStrLn "────────────────────────────────────────────────────────────"

mostrarTitulo :: String -> IO ()
mostrarTitulo titulo = do
    putStrLn ""
    putStrLn "╔════════════════════════════════════════════════════════════╗"
    putStrLn $ "║  " ++ titulo ++ completarEspacios (58 - length titulo) ++ "║"
    putStrLn "╚════════════════════════════════════════════════════════════╝"

mostrarMenu :: String -> [String] -> IO ()
mostrarMenu titulo opciones = do
    putStrLn ""
    putStrLn "╔════════════════════════════════════════════════════════════╗"
    putStrLn $ "║  " ++ titulo ++ completarEspacios (58 - length titulo) ++ "║"
    putStrLn "╠════════════════════════════════════════════════════════════╣"
    mapM_ imprimirOpcion opciones
    putStrLn "╚════════════════════════════════════════════════════════════╝"
  where
    imprimirOpcion texto = putStrLn $ "║  " ++ texto ++ completarEspacios (58 - length texto) ++ "║"

completarEspacios :: Int -> String
completarEspacios n = replicate (max 1 n) ' '

pausar :: IO ()
pausar = do
    putStr "\nPresiona Enter para continuar..."
    _ <- getLine
    return ()

prompt :: String -> IO String
prompt texto = do
    putStr texto
    getLine

formatoMonto :: Monto -> String
formatoMonto valor = "₡" ++ printf "%.2f" valor

formatoFecha :: Fecha -> String
formatoFecha = formatTime defaultTimeLocale "%Y-%m-%d"

formatoMes :: (Integer, Int) -> String
formatoMes (anio, mes) = printf "%02d/%d" mes anio

showTipo :: TipoRegistro -> String
showTipo Ingreso   = "Ingreso"
showTipo Gasto     = "Gasto"
showTipo Ahorro    = "Ahorro"
showTipo Inversion = "Inversion"

mostrarRegla :: Regla -> String
mostrarRegla (ReglaGastoMax cat maximo) =
    "Gasto maximo en " ++ cat ++ ": " ++ formatoMonto maximo
mostrarRegla (ReglasAhorroMin minimo) =
    "Ahorro minimo acumulado: " ++ formatoMonto minimo




leerOpcion :: IO Int
leerOpcion = do
    texto <- prompt "Opcion: "
    case readMaybe texto of
        Just n  -> return n
        Nothing -> do
            putStrLn "La entrada fue invalida, por favor digite un numero"
            leerOpcion

leerDouble :: String -> IO Double
leerDouble mensaje = do
    texto <- prompt mensaje
    case readMaybe texto of
        Just n  -> return n
        Nothing -> do
            putStrLn "La entrada fue invalida, por favor digite un numero que sea valido"
            leerDouble mensaje

leerInt :: String -> IO Int
leerInt mensaje = do
    texto <- prompt mensaje
    case readMaybe texto of
        Just n  -> return n
        Nothing -> do
            putStrLn "La entrada fue invalida, por favor digite un numero entero"
            leerInt mensaje

leerEnteroPositivo :: String -> IO Int
leerEnteroPositivo mensaje = do
    n <- leerInt mensaje
    if n > 0
        then return n
        else do
            putStrLn "El numero debe ser mayor que cero"
            leerEnteroPositivo mensaje

leerTipoRegistro :: IO TipoRegistro
leerTipoRegistro = do
    mostrarMenu "TIPO DE REGISTRO"
        [ "1. Ingreso"
        , "2. Gasto"
        , "3. Ahorro"
        , "4. Inversion"
        ]
    opcion <- leerOpcion
    case opcion of
        1 -> return Ingreso
        2 -> return Gasto
        3 -> return Ahorro
        4 -> return Inversion
        _ -> do
            putStrLn "Opcion invalida."
            leerTipoRegistro

leerFechaValidada :: String -> IO Fecha
leerFechaValidada mensaje = do
    texto <- prompt mensaje
    case validarFecha texto of
        Right f -> return f
        Left e  -> do
            putStrLn e
            leerFechaValidada mensaje

trim :: String -> String
trim = quitar . quitar
  where
    quitar = reverse . dropWhile isSpace

splitPor :: Char -> String -> [String]
splitPor _ "" = [""]
splitPor sep texto = foldr separar [""] texto
  where
    separar c (x:xs)
        | c == sep  = "" : x : xs
        | otherwise = (c:x) : xs
    separar _ [] = []

leerEtiquetas :: IO [Etiquetas]
leerEtiquetas = do
    texto <- prompt "Etiquetas separadas por coma (Enter si no aplica): "
    return $ filter (not . null) $ map trim $ splitPor ',' texto







-- Menu principal

iniciarInterfaz
    :: [RegistroFinanciero]
    -> [Presupuesto]
    -> [Regla]
    -> IO ([RegistroFinanciero], [Presupuesto], [Regla])
iniciarInterfaz registros presupuestos reglas = do
    mostrarMenu "SISTEMA DE FINANZAS PERSONALES"
        [ "1. Agregar registro"
        , "2. Ver registros con filtros"
        , "3. Gestionar presupuestos"
        , "4. Gestionar reglas"
        , "5. Ver analisis financiero"
        , "6. Simulacion de escenarios"
        , "7. Generar reportes"
        , "8. Salir"
        ]
    opcion <- leerOpcion
    case opcion of
        1 -> do
            nuevosRegistros <- menuAgregarRegistro registros
            iniciarInterfaz nuevosRegistros presupuestos reglas
        2 -> do
            menuVerRegistros registros
            iniciarInterfaz registros presupuestos reglas
        3 -> do
            nuevosPresupuestos <- menuPresupuestos registros presupuestos
            iniciarInterfaz registros nuevosPresupuestos reglas
        4 -> do
            nuevasReglas <- menuReglas registros reglas
            iniciarInterfaz registros presupuestos nuevasReglas
        5 -> do
            menuAnalisis registros presupuestos reglas
            iniciarInterfaz registros presupuestos reglas
        6 -> do
            menuSimulacion registros
            iniciarInterfaz registros presupuestos reglas
        7 -> do
            menuReportes registros
            iniciarInterfaz registros presupuestos reglas
        8 -> do
            putStrLn "\nGuardando informacion antes de salir..."
            return (registros, presupuestos, reglas)
        _ -> do
            putStrLn "Opcion invalida."
            iniciarInterfaz registros presupuestos reglas






-- 1. Agregar registro


menuAgregarRegistro :: [RegistroFinanciero] -> IO [RegistroFinanciero]
menuAgregarRegistro registros = do
    mostrarTitulo "AGREGAR REGISTRO FINANCIERO"
    tipoRegistro <- leerTipoRegistro
    montoRegistro <- leerDouble "Monto: "
    categoriaRegistro <- prompt "Categoria: "
    fechaRegistro <- prompt "Fecha (YYYY-MM-DD): "
    descripcionRegistro <- prompt "Descripcion: "
    etiquetasRegistro <- leerEtiquetas

    case validarRegistro montoRegistro categoriaRegistro fechaRegistro descripcionRegistro etiquetasRegistro tipoRegistro of
        Right registro -> do
            putStrLn "\n[OK] Registro agregado correctamente"
            mostrarRegistro 1 registro
            pausar
            return (registros ++ [registro])
        Left errorValidacion -> do
            putStrLn $ "\n[Error] " ++ errorValidacion
            pausar
            return registros





-- 2. Ver registros y filtros


menuVerRegistros :: [RegistroFinanciero] -> IO ()
menuVerRegistros registros = do
    mostrarMenu "VER REGISTROS"
        [ "1. Ver todos"
        , "2. Filtrar por tipo"
        , "3. Filtrar por categoria"
        , "4. Filtrar por etiqueta"
        , "5. Filtrar por rango de fechas"
        , "6. Volver"
        ]
    opcion <- leerOpcion
    case opcion of
        1 -> mostrarListaRegistros "TODOS LOS REGISTROS" registros >> pausar
        2 -> do
            t <- leerTipoRegistro
            mostrarListaRegistros ("REGISTROS DE TIPO " ++ showTipo t) (filtrarPorTipo t registros)
            pausar
        3 -> do
            cat <- prompt "Categoria a buscar: "
            mostrarListaRegistros ("REGISTROS DE CATEGORIA " ++ cat) (filtrarPorCategoria cat registros)
            pausar
        4 -> do
            etq <- prompt "Etiqueta a buscar: "
            mostrarListaRegistros ("REGISTROS CON ETIQUETA " ++ etq) (filtrarPorEtiqueta etq registros)
            pausar
        5 -> do
            inicio <- leerFechaValidada "Fecha inicial (YYYY-MM-DD): "
            fin <- leerFechaValidada "Fecha final (YYYY-MM-DD): "
            mostrarListaRegistros "REGISTROS DEL PERIODO" (filtrarPorRangoFecha inicio fin registros)
            pausar
        6 -> return ()
        _ -> do
            putStrLn "Opcion invalida"
            menuVerRegistros registros

mostrarListaRegistros :: String -> [RegistroFinanciero] -> IO ()
mostrarListaRegistros titulo registros = do
    mostrarTitulo titulo
    if null registros
        then putStrLn "No hay registros para mostrar"
        else mapM_ (uncurry mostrarRegistro) (zip [1..] registros)

mostrarRegistro :: Int -> RegistroFinanciero -> IO ()
mostrarRegistro indice r = do
    let etiquetasTexto = if null (etiquetas r) then "Sin etiquetas" else intercalate ", " (etiquetas r)
    putStrLn $ "#" ++ show indice
    putStrLn $ "  Tipo:        " ++ showTipo (tipo r)
    putStrLn $ "  Monto:       " ++ formatoMonto (monto r)
    putStrLn $ "  Categoria:   " ++ categoria r
    putStrLn $ "  Fecha:       " ++ formatoFecha (fecha r)
    putStrLn $ "  Descripcion: " ++ descripcion r
    putStrLn $ "  Etiquetas:   " ++ etiquetasTexto
    separador






-- 3. Gestionar presupuestos


menuPresupuestos :: [RegistroFinanciero] -> [Presupuesto] -> IO [Presupuesto]
menuPresupuestos registros presupuestos = do
    mostrarMenu "GESTION DE PRESUPUESTOS"
        [ "1. Ver presupuestos"
        , "2. Agregar o actualizar presupuesto"
        , "3. Eliminar presupuesto"
        , "4. Verificar presupuestos contra gastos reales"
        , "5. Volver"
        ]
    opcion <- leerOpcion
    case opcion of
        1 -> do
            mostrarPresupuestos presupuestos
            pausar
            menuPresupuestos registros presupuestos
        2 -> do
            nuevo <- pedirPresupuesto
            let actualizados = agregarOActualizarPresupuesto nuevo presupuestos
            putStrLn "[OK] Presupuesto guardado"
            pausar
            menuPresupuestos registros actualizados
        3 -> do
            actualizados <- eliminarPresupuesto presupuestos
            pausar
            menuPresupuestos registros actualizados
        4 -> do
            mostrarAlertas "ALERTAS DE PRESUPUESTO" (verificarPresupuestos presupuestos registros)
            pausar
            menuPresupuestos registros presupuestos
        5 -> return presupuestos
        _ -> do
            putStrLn "Opcion invalida"
            menuPresupuestos registros presupuestos

pedirPresupuesto :: IO Presupuesto
pedirPresupuesto = do
    cat <- prompt "Categoria del presupuesto: "
    lim <- leerDouble "Limite de gasto: "
    if null (trim cat) || lim <= 0
        then do
            putStrLn "La categoria no puede estar vacia y el limite debe ser positivo"
            pedirPresupuesto
        else return Presupuesto { catPresupuesto = trim cat, limite = lim }

agregarOActualizarPresupuesto :: Presupuesto -> [Presupuesto] -> [Presupuesto]
agregarOActualizarPresupuesto nuevo presupuestos =
    nuevo : filter (\p -> map toLower (catPresupuesto p) /= map toLower (catPresupuesto nuevo)) presupuestos

mostrarPresupuestos :: [Presupuesto] -> IO ()
mostrarPresupuestos presupuestos = do
    mostrarTitulo "PRESUPUESTOS REGISTRADOS"
    if null presupuestos
        then putStrLn "No hay presupuestos registrados"
        else mapM_ imprimir (zip [1..] presupuestos)
  where
    imprimir (i, p) = do
        putStrLn $ show i ++ ". " ++ catPresupuesto p ++ " -> " ++ formatoMonto (limite p)
        separador

eliminarPresupuesto :: [Presupuesto] -> IO [Presupuesto]
eliminarPresupuesto presupuestos = do
    mostrarPresupuestos presupuestos
    if null presupuestos
        then return presupuestos
        else do
            indice <- leerInt "Numero de presupuesto a eliminar: "
            if indice >= 1 && indice <= length presupuestos
                then do
                    putStrLn "[OK] Presupuesto eliminado"
                    return (eliminarPorIndice indice presupuestos)
                else do
                    putStrLn "Indice invalido"
                    return presupuestos





-- 4. Gestionar reglas


menuReglas :: [RegistroFinanciero] -> [Regla] -> IO [Regla]
menuReglas registros reglas = do
    mostrarMenu "GESTION DE REGLAS"
        [ "1. Ver reglas"
        , "2. Crear regla de gasto maximo por categoria"
        , "3. Crear regla de ahorro minimo"
        , "4. Eliminar regla"
        , "5. Evaluar reglas"
        , "6. Volver"
        ]
    opcion <- leerOpcion
    case opcion of
        1 -> do
            mostrarReglas reglas
            pausar
            menuReglas registros reglas
        2 -> do
            cat <- prompt "Categoria: "
            maximo <- leerDouble "Monto maximo permitido: "
            if null (trim cat) || maximo <= 0
                then putStrLn "Datos invalidos. No se creo la regla"
                else putStrLn "[OK] Regla creada"
            let nuevas = if null (trim cat) || maximo <= 0
                         then reglas
                         else reglas ++ [ReglaGastoMax (trim cat) maximo]
            pausar
            menuReglas registros nuevas
        3 -> do
            minimo <- leerDouble "Ahorro minimo acumulado esperado: "
            if minimo <= 0
                then do
                    putStrLn "El monto debe ser positivo."
                    pausar
                    menuReglas registros reglas
                else do
                    putStrLn "[OK] Regla creada"
                    pausar
                    menuReglas registros (reglas ++ [ReglasAhorroMin minimo])
        4 -> do
            nuevas <- eliminarRegla reglas
            pausar
            menuReglas registros nuevas
        5 -> do
            mostrarAlertas "ALERTAS DEL SISTEMA DE REGLAS" (evaluarReglas reglas registros)
            pausar
            menuReglas registros reglas
        6 -> return reglas
        _ -> do
            putStrLn "Opcion invalida"
            menuReglas registros reglas

mostrarReglas :: [Regla] -> IO ()
mostrarReglas reglas = do
    mostrarTitulo "REGLAS REGISTRADAS"
    if null reglas
        then putStrLn "No hay reglas registradas"
        else mapM_ imprimir (zip [1..] reglas)
  where
    imprimir (i, r) = do
        putStrLn $ show i ++ ". " ++ mostrarRegla r
        separador

eliminarRegla :: [Regla] -> IO [Regla]
eliminarRegla reglas = do
    mostrarReglas reglas
    if null reglas
        then return reglas
        else do
            indice <- leerInt "Numero de regla a eliminar: "
            if indice >= 1 && indice <= length reglas
                then do
                    putStrLn "[OK] Regla eliminada"
                    return (eliminarPorIndice indice reglas)
                else do
                    putStrLn "Indice invalido"
                    return reglas






-- 5. Analisis financiero


menuAnalisis :: [RegistroFinanciero] -> [Presupuesto] -> [Regla] -> IO ()
menuAnalisis registros presupuestos reglas = do
    mostrarTitulo "ANALISIS FINANCIERO"
    if null registros
        then putStrLn "No hay registros suficientes para analizar"
        else do
            imprimirResumenGeneral registros
            imprimirFlujoCaja registros
            imprimirTendencias registros
            imprimirCategoriasImpacto registros
            mostrarAlertas "ALERTAS ACTIVAS" (verificarPresupuestos presupuestos registros ++ evaluarReglas reglas registros)
    pausar

imprimirResumenGeneral :: [RegistroFinanciero] -> IO ()
imprimirResumenGeneral registros = do
    putStrLn "RESUMEN GENERAL"
    putStrLn $ "  Ingresos totales:    " ++ formatoMonto (totalPorTipo Ingreso registros)
    putStrLn $ "  Gastos totales:      " ++ formatoMonto (totalPorTipo Gasto registros)
    putStrLn $ "  Ahorros totales:     " ++ formatoMonto (totalPorTipo Ahorro registros)
    putStrLn $ "  Inversiones totales: " ++ formatoMonto (totalPorTipo Inversion registros)
    putStrLn $ "  Balance total:       " ++ formatoMonto (balance registros)
    putStrLn $ "  Proyeccion gasto mensual promedio: " ++ formatoMonto (proyeccionGasto registros)
    separador

imprimirFlujoCaja :: [RegistroFinanciero] -> IO ()
imprimirFlujoCaja registros = do
    putStrLn "FLUJO DE CAJA MENSUAL"
    let flujos = flujoCajaMensual registros
    if null flujos
        then putStrLn "  Sin datos"
        else mapM_ imprimir flujos
    separador
  where
    imprimir (mes, valor) = putStrLn $ "  " ++ formatoMes mes ++ " -> " ++ formatoMonto valor

imprimirTendencias :: [RegistroFinanciero] -> IO ()
imprimirTendencias registros = do
    putStrLn "TENDENCIA DE GASTOS"
    let gastos = tendenciaGasto registros
    case gastos of
        [] -> putStrLn "  Sin datos de gastos"
        _  -> mapM_ imprimir (zip gastos (Nothing : map Just gastos))
    separador
  where
    imprimir ((mes, total), Nothing) =
        putStrLn $ "  " ++ formatoMes mes ++ " -> " ++ formatoMonto total ++ " (mes base)"
    imprimir ((mes, total), Just (_, anterior)) =
        let diferencia = total - anterior
            texto
                | diferencia > 0 = "aumento " ++ formatoMonto diferencia
                | diferencia < 0 = "disminuyo " ++ formatoMonto (abs diferencia)
                | otherwise      = "sin cambios"
        in putStrLn $ "  " ++ formatoMes mes ++ " -> " ++ formatoMonto total ++ " (" ++ texto ++ ")"

imprimirCategoriasImpacto :: [RegistroFinanciero] -> IO ()
imprimirCategoriasImpacto registros = do
    putStrLn "CATEGORIAS CON MAYOR GASTO"
    let principales = categoriasMayorGasto 5 registros
    if null principales
        then putStrLn "  No hay gastos registrados"
        else mapM_ imprimir principales
    case categoriaMayorImpacto registros of
        Nothing -> return ()
        Just (cat, valor) -> putStrLn $ "\nMayor impacto financiero general: " ++ cat ++ " -> " ++ formatoMonto valor
    separador
  where
    imprimir (cat, valor) = putStrLn $ "  " ++ cat ++ " -> " ++ formatoMonto valor

mostrarAlertas :: String -> [String] -> IO ()
mostrarAlertas titulo alertas = do
    mostrarTitulo titulo
    if null alertas
        then putStrLn "No hay alertas activas"
        else mapM_ (putStrLn . ("- " ++)) alertas
    separador







-- 6. Simulacion financiera


menuSimulacion :: [RegistroFinanciero] -> IO ()
menuSimulacion registros = do
    mostrarTitulo "SIMULACION DE ESCENARIOS"
    if null registros
        then putStrLn "No hay registros para simular"
        else do
            porcentaje <- leerDouble "Porcentaje de reduccion de gastos: "
            meses <- leerEnteroPositivo "Cantidad de meses para proyectar ahorro: "
            let registrosSimulados = simularReduccionGastos porcentaje registros
                gastoActual        = totalPorTipo Gasto registros
                gastoSimulado      = totalPorTipo Gasto registrosSimulados
                ahorroEstimado     = gastoActual - gastoSimulado
                balanceActual      = balance registros
                balanceSimulado    = balance registrosSimulados
                ahorroHistorico    = proyeccionAhorro meses registros
                ahorroExtra        = ahorroEstimado * fromIntegral meses
            putStrLn ""
            putStrLn $ "Gasto actual total:          " ++ formatoMonto gastoActual
            putStrLn $ "Gasto simulado total:        " ++ formatoMonto gastoSimulado
            putStrLn $ "Ahorro por reduccion:        " ++ formatoMonto ahorroEstimado
            putStrLn $ "Balance actual:              " ++ formatoMonto balanceActual
            putStrLn $ "Balance con escenario:       " ++ formatoMonto balanceSimulado
            putStrLn $ "Ahorro historico proyectado: " ++ formatoMonto ahorroHistorico
            putStrLn $ "Ahorro extra en " ++ show meses ++ " meses:       " ++ formatoMonto ahorroExtra
    pausar








-- 7. Reportes


menuReportes :: [RegistroFinanciero] -> IO ()
menuReportes registros = do
    mostrarMenu "GENERAR REPORTES"
        [ "1. Reporte mensual"
        , "2. Comparacion entre periodos"
        , "3. Categorias con mayor gasto"
        , "4. Volver"
        ]
    opcion <- leerOpcion
    case opcion of
        1 -> do
            reporteMensual registros
            pausar
            menuReportes registros
        2 -> do
            reporteComparacion registros
            pausar
            menuReportes registros
        3 -> do
            reporteCategorias registros
            pausar
            menuReportes registros
        4 -> return ()
        _ -> do
            putStrLn "Opcion invalida"
            menuReportes registros

reporteMensual :: [RegistroFinanciero] -> IO ()
reporteMensual registros = do
    anio <- leerInt "Anio del reporte: "
    mes <- leerInt "Mes del reporte (1-12): "
    if mes < 1 || mes > 12
        then putStrLn "Mes invalido"
        else do
            let contenido = resumenMensual (fromIntegral anio) mes registros
                ruta = printf "Reportes/reporte_mensual_%d_%02d.txt" anio mes
            guardarReporte ruta contenido

reporteComparacion :: [RegistroFinanciero] -> IO ()
reporteComparacion registros = do
    putStrLn "Periodo 1"
    ini1 <- leerFechaValidada "Fecha inicial (YYYY-MM-DD): "
    fin1 <- leerFechaValidada "Fecha final (YYYY-MM-DD): "
    putStrLn "\nPeriodo 2"
    ini2 <- leerFechaValidada "Fecha inicial (YYYY-MM-DD): "
    fin2 <- leerFechaValidada "Fecha final (YYYY-MM-DD): "
    let contenido = comparacionPeriodos (ini1, fin1) (ini2, fin2) registros
        ruta = "Reportes/reporte_comparacion_periodos.txt"
    guardarReporte ruta contenido

reporteCategorias :: [RegistroFinanciero] -> IO ()
reporteCategorias registros = do
    n <- leerEnteroPositivo "Cantidad de categorias a incluir: "
    let datos = categoriasMayorGasto n registros
        contenido = unlines $ "=== Categorias con mayor gasto ===" :
            map (\(cat, valor) -> cat ++ ": " ++ formatoMonto valor) datos
        ruta = "Reportes/reporte_categorias_mayor_gasto.txt"
    guardarReporte ruta contenido

guardarReporte :: FilePath -> String -> IO ()
guardarReporte ruta contenido = do
    createDirectoryIfMissing True "Reportes"
    writeFile ruta contenido
    putStrLn ""
    putStrLn contenido
    putStrLn $ "[OK] Reporte guardado en: " ++ ruta







-- Utilidades generales

eliminarPorIndice :: Int -> [a] -> [a]
eliminarPorIndice indice xs = take (indice - 1) xs ++ drop indice xs
