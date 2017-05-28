{renderable, button, span} = require("teacup")

selector = (id) ->
  "#{id}.btn.btn-link.btn-xs"

module.exports =
  editButton: renderable (id, opts = {}) ->
    button selector(id), opts, ->
      span ".glyphicon.glyphicon-pencil"

  trashButton: renderable (id, opts = {}) ->
    button selector(id), opts, ->
      span ".glyphicon.glyphicon-trash"

  undoButton: renderable (id, opts = {}) ->
    button selector(id), opts, ->
      span ".fa.fa-undo"
