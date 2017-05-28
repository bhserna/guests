{renderable, div, h4, p, strong, br, span} = require("teacup")

module.exports = renderable ->
  div ".alert.alert-info", style: "margin-top: 1em", ->
    h4 "Registra a tus invitados por invitación o familia"

    p ->
      strong "1. Escribe el nombre de la invitación."
      br()
      span "Ejemplo: 'Familia Perez Martinez' o 'Carlos Hernandez y Sra.'"
      br()
      span "Consejo: Usa 'Enter' en lugar de dar click en 'Agregar'"

    p ->
      strong "2. Agrega el nombre de las personas en esa invitación."
      br()
      span "Consejo: Usa 'Enter' en lugar de dar click en 'Agregar'"

    p ->
      strong "3. Da click en Guarda invitación"
