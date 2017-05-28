{renderable, div, label, small, br, strong} = require("teacup")

module.exports =
  invitationField: renderable (content) ->
    div style: "margin-bottom: 1em", content

  invitationLabel: renderable (text) ->
    label ->
      small ".text-muted", text

  invitationValue: renderable (text) ->
    br()
    strong text
