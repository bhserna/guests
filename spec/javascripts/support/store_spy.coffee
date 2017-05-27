class FunctionCall
  constructor: (@name, @params) ->

class StoreSpy
  constructor: (@real) ->
    @functionCalls = []

  first: () ->
    @real.first()

  find: (id) ->
    @real.find(id)

  saveRecord: (record) ->
    @functionCalls.push(new FunctionCall("saveRecord", record))
    @real.saveRecord(record)

  updateRecord: (record) ->
    @functionCalls.push(new FunctionCall("updateRecord", record))
    @real.updateRecord(record)

  deleteRecord: (id) ->
    @functionCalls.push(new FunctionCall("deleteRecord", id))
    @real.deleteRecord(id)

  loadRecords: (listener) ->
    @real.loadRecords(listener)

  allFunctionCalls: ->
    if @functionCalls.length then @functionCalls else "No calls"

module.exports = StoreSpy
