_ = require("underscore")
{renderable, input} = require("teacup")

defaultInput = renderable (id, opts = {}) ->
  input "#{id}.form-control", _.extend({
    type: "text",
    style: "margin-right: 5px; margin-bottom: 5px;"
  }, opts)

module.exports =
  textInput: defaultInput

  phoneInput: renderable (id, opts = {}) ->
    defaultInput id, _.extend(opts, type: "phone")

  emailInput: renderable (id, opts = {}) ->
    defaultInput id, _.extend(opts, type: "email")
