_ = require("underscore")
StoreSpy = require("./support/store_spy.coffee")
TestDisplay = require("./support/test_display.coffee")
addInvitation = require("./support/add_invitation.coffee")
{test, module} = QUnit
first = (list) -> list[0]
last = (list) -> _.last(list)

module "Confirm invitation invitation assistance", (hooks) ->
  hooks.beforeEach ->
    @store = new StoreSpy(new MemoryStore)
    @page = new TestDisplay
    @app = new GuestsApp(@store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "12341234")

  test "unstarted", (assert) ->
    invitation = => first @app.getInvitations()
    assert.notOk invitation().isAssistanceConfirmed
    assert.equal @app.totalConfirmedGuests(), 0

  test "confirm", (assert) ->
    invitation = => first @app.getInvitations()

    confirmation = @app.newAssistanceConfirmation(invitation().id)
    assert.equal confirmation.title, "Inv 1"
    assert.equal confirmation.phone, "12341234"
    assert.equal confirmation.confirmedGuestsCount, undefined
    assert.equal @app.totalConfirmedGuests(), 0

    assert.ok @app.confirmGuests(2)
    assert.ok invitation().isAssistanceConfirmed
    assert.equal invitation().confirmedGuestsCount, 2
    assert.equal @app.totalConfirmedGuests(), 2

    call = last @store.allFunctionCalls()
    assert.equal call.name, "updateRecord"
    assert.equal call.params, invitation()

  test "confirm without value", (assert) ->
    invitation = => first @app.getInvitations()
    confirmation = @app.newAssistanceConfirmation(invitation().id)
    assert.notOk @app.confirmGuests("")
    assert.equal @app.totalConfirmedGuests(), 0

  test "update without value", (assert) ->
    invitation = => first @app.getInvitations()
    @app.newAssistanceConfirmation(invitation().id)
    @app.confirmGuests(2)
    @app.newAssistanceConfirmation(invitation().id)
    @app.confirmGuests("")
    confirmation = @app.newAssistanceConfirmation(invitation().id)
    assert.equal confirmation.confirmedGuestsCount, 2
    assert.equal @app.totalConfirmedGuests(), 2

  test "cancel", (assert) ->
    invitation = => first @app.getInvitations()
    @app.newAssistanceConfirmation(invitation().id)
    @app.cancelAssistanceConfirmation()
    assert.notOk @app.confirmGuests(2)
    assert.equal @app.totalConfirmedGuests(), 0
