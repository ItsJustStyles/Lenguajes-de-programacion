# Servicio que automatiza el paso entre la fase de grupos y la fase
# eliminatoria.
#
# Su responsabilidad es pequeña y concreta: cuando la fase de grupos ya está
# completamente registrada y todavía no existe el cuadro eliminatorio, calcula
# los 32 clasificados y genera los dieciseisavos de final.
#
# Esto vuelve automático el arranque de la Fase 8 después del último resultado
# de grupos, sin quitar el botón manual del dashboard (que queda como respaldo
# idempotente para el usuario).
#
# Uso:
#   AutoBracketService.new.call
class AutoBracketService
  # Intenta generar el cuadro inicial de eliminatoria.
  # Devuelve los partidos creados o [] si todavía no corresponde hacer nada.
  def call
    status = TournamentStatusService.new
    return [] unless status.ready_for_knockout?

    QualificationService.new.call
    BracketGenerator.new.call
  rescue QualificationService::GroupStageIncompleteError,
         BracketGenerator::NotEnoughQualifiedError
    []
  end
end
