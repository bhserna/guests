{renderable, div, p} = require("teacup")

module.exports = renderable ->
  div ".alert.alert-warning", style: "margin-top: 1em", ->
    p "Los datos de esta lista no se guardan y se perderán al refrescar el navegador."
    p "Registrate para crear listas y guardar los datos en tu cuenta."
