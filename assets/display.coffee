layoutView = require("./display/layout-view.coffee")
confirmatorView = require("./display/confirmator-view.coffee")

class Display
  constructor: ->
    @editor = null
    @list = null

  renderEditor: (data) ->
    @editor = data
    @render()

  renderList: (data) ->
    @list = data
    @render()

  renderConfirmator: (data) ->
    @$confirmator = $(confirmatorView(data))
    $("body").append(@$confirmator)
    @$confirmator.on 'shown.bs.modal', -> $("#guests_count").focus()
    @$confirmator.modal(backdrop: false, keybord: false)

  removeConfirmator: ->
    @$confirmator.modal("hide")
    @$confirmator.on 'hidden.bs.modal', => @$confirmator.remove()

  render: ->
    if @editor and @list
      html = layoutView
        editor: @editor
        list: @list
        isDemo: $("#app").data("listId")
      $("#app").html(html)

module.exports = Display
