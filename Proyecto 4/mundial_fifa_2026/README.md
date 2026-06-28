# Sistema de Gestión de la Copa Mundial FIFA 2026

Aplicación web en **Ruby on Rails 7.1** para gestionar la Copa Mundial 2026:
48 selecciones en 12 grupos, fase de grupos con tabla de posiciones automática y
fase de eliminación directa hasta determinar al campeón.

Proyecto 4 del curso de Lenguajes de Programación.

---

## Requisitos previos

- **Ruby 3.2.x** (el proyecto se fija en la versión indicada en `.ruby-version`: 3.2.3)
- **Bundler** (`gem install bundler`)
- **SQLite 3**

### En Linux / WSL (Ubuntu/Debian)

Hay que instalar los encabezados de desarrollo para poder compilar las gemas
nativas (esto es obligatorio, sin ello falla `bundle install`):

```bash
sudo apt-get update
sudo apt-get install -y ruby-dev build-essential libsqlite3-dev
```

> Nota: en algunas instalaciones de Ubuntu el ejecutable de bundler se llama
> `bundle3.2` en lugar de `bundle`. Si `bundle` no existe, usá `bundle3.2`
> en los comandos siguientes (o usá directamente `bin/rails ...`).

### En macOS

```bash
brew install ruby sqlite3
```

### En Windows

Se recomienda usar **WSL2** con Ubuntu y seguir las instrucciones de Linux.

---

## Pasos de instalación

```bash
# 1. Clonar el repositorio y entrar a la carpeta de la app
cd "Proyecto 4/mundial_fifa_2026"

# 2. Instalar las gemas del proyecto
bundle install

# 3. Crear la base de datos, aplicar migraciones y cargar datos iniciales
#    (los 12 grupos y las 48 selecciones)
bin/rails db:setup
#    db:setup = db:create + db:migrate + db:seed
#    Si la base ya existe, podés correr:  bin/rails db:migrate db:seed

# 4. Levantar el servidor
bin/rails server
```

Luego abrir en el navegador: **http://localhost:3000**

---

## Flujo de uso

1. **Selecciones y grupos** ya vienen cargados por el seed (12 grupos, 48 equipos).
   Se pueden administrar (CRUD) en `/groups` y `/teams`.
2. **Generar fase de grupos**: crea los 72 partidos (6 por grupo).
3. **Registrar resultados** de cada partido: la tabla de posiciones se recalcula
   automáticamente (puntos → diferencia de goles → goles a favor).
4. Al completarse todos los grupos, **generar la fase eliminatoria**: clasifican
   1.º y 2.º de cada grupo más los 8 mejores terceros (32 equipos).
5. **Registrar resultados** de la eliminatoria (incluye penales en caso de empate).
   El ganador avanza automáticamente a la siguiente ronda.
6. Ver el **campeón, subcampeón y tercer lugar** del Mundial.

---

## Arquitectura

- **Modelos** (`app/models`): `Group`, `Team`, `Match`.
- **Servicios** (`app/services`): toda la lógica de negocio, siguiendo el
  principio de responsabilidad única (SOLID):
  - `GroupFixtureGenerator` — genera los partidos de la fase de grupos
  - `StandingsCalculator` — calcula la tabla de posiciones de un grupo
  - `QualificationService` — determina los 32 clasificados
  - `BracketGenerator` — arma el cuadro de dieciseisavos
  - `KnockoutAdvancer` — hace avanzar la eliminatoria automáticamente
  - `MatchResultProcessor` — registra un resultado y dispara los efectos
  - `TournamentStatusService` — consulta el estado global del torneo
- **Controladores** (`app/controllers`): `GroupsController`, `TeamsController`,
  `MatchesController`, `TournamentController`.

> Nota: la interfaz gráfica (vistas) corresponde a la Fase 5 y se agrega después.

---

## Datos

Se usa **SQLite**. La base de datos (`storage/*.sqlite3`) NO se versiona: cada
quien la genera localmente con `bin/rails db:setup`.
