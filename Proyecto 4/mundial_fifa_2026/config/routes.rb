Rails.application.routes.draw do
  # Estado de salud de la app (usado por Rails por defecto).
  get "up" => "rails/health#show", as: :rails_health_check

  # CRUD completo de grupos y selecciones (requisitos 1 y 2 del enunciado).
  resources :groups
  resources :teams

  # Partidos: se listan, se ven y se registra su resultado. No se crean/eliminan
  # manualmente porque los genera el sistema (fixtures de grupo y cuadro).
  resources :matches, only: [:index, :show, :edit, :update] do
    member do
      patch :register_result # registra goles (y penales) de un partido
    end
  end

  # Acciones de gestión del torneo, agrupadas en el TournamentController.
  controller :tournament do
    get  "tournament/standings",        action: :standings,        as: :tournament_standings
    get  "tournament/bracket",          action: :bracket,          as: :tournament_bracket
    get  "tournament/champion",         action: :champion,         as: :tournament_champion
    post "tournament/generate_groups",  action: :generate_groups,  as: :tournament_generate_groups
    post "tournament/generate_bracket", action: :generate_bracket, as: :tournament_generate_bracket
  end

  # Página principal: tablas de posiciones / panel del torneo.
  root "tournament#standings"
end
