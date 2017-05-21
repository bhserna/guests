_ = require("underscore")
addInvitation = require("./support/add_invitation.coffee")
StoreSpy = require("./support/store_spy.coffee")
TestDisplay = require("./support/test_display.coffee")
first = (list) -> list[0]
second = (list) -> list[1]
last = (list) -> _.last(list)
{test, module} = QUnit

module "Edit invitation", (hooks) ->
  hooks.beforeEach ->
    @store = new StoreSpy(new MemoryStore)
    @page = new TestDisplay
    @app = new GuestsApp(@store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "1234", "b@g.com")

  test "knows is not a new invitation", (assert) ->
    invitation = @app.editInvitation(@store.first().id)
    assert.notOk invitation.isNewInvitation

  test "it start with the title in non edition mode", (assert) ->
    invitation = @app.editInvitation(@store.first().id)
    assert.notOk invitation.isEditingTitle

  test "it has the information of the invitation to edit", (assert) ->
    invitation = @app.editInvitation(@store.first().id)
    assert.equal invitation.title, "Inv 1"
    assert.equal first(invitation.guests).name, "guest1"
    assert.equal second(invitation.guests).name, "guest2"
    assert.equal invitation.phone, "1234"
    assert.equal invitation.email, "b@g.com"

  test "after commit it updates the invitation in the store", (assert) ->
    invitation = @app.editInvitation(@store.first().id)
    @app.addInvitationTitle("Serna Moreno")
    @app.updateGuest(first(invitation.guests).id, name: "Benito Serna")
    @app.updateGuest(second(invitation.guests).id, name: "Maripaz Moreno")
    @app.saveInvitation()

    call = last @store.allFunctionCalls()
    assert.equal call.name, "updateRecord"
    record = call.params
    assert.equal record.title, "Serna Moreno"
    assert.equal first(record.guests).name, "Benito Serna"
    assert.equal second(record.guests).name, "Maripaz Moreno"

  test "after commit it returns to adding invitation mode", (assert) ->
    @app.editInvitation(@store.first().id)
    @app.saveInvitation()
    invitation = @app.currentInvitation()
    assert.ok invitation.isNewInvitation
    assert.equal invitation.title, ""
    assert.equal invitation.guests.length, 0

