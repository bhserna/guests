class TestDisplay
  editor: {}
  list: {}
  confirmator: {}

  renderEditor: (data) ->
    @editor = data

  renderList: (data) ->
    @list = data

  renderConfirmator: (data) ->
    @confirmator = data

  removeConfirmator: ->
    @confirmator = {}

module.exports = TestDisplay
