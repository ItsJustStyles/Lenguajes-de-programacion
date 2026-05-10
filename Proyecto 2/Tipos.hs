module Tipos where

-- Imports:
import Data.Time.Clock (UTCTime)

-- Datos del registro:
type Monto = Double
type Categoria = String
type Fecha = UTCTime
type Descripcion = String
type Etiquetas = String

data TipoRegistro = Ingreso | Gasto | Ahorro | Inversion 
    deriving (Show, Read, Eq)

data RegistroFinanciero = Registro {
    monto :: Monto,
    categoria :: Categoria,
    fecha :: Fecha,
    descripcion :: Descripcion,
    etiquetas :: [Etiquetas],
    tipo :: TipoRegistro
} deriving(Show, Read, Eq)

data Presupuesto = Presupuesto {
    catPresupuesto :: Categoria,
    limite :: Monto
} deriving(Show, Read, Eq)

data Regla = ReglaGastoMax Categoria Monto | ReglasAhorroMin Monto
    deriving(Show, Read, Eq)