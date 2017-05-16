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
    listInvitation = => first @page.list.invitations
    assert.notOk @app.confirmator
    assert.notOk @page.confirmator.title
    assert.notOk listInvitation().isAssistanceConfirmed
    assert.equal @page.list.totalConfirmedGuests(), 0

  test "confirm", (assert) ->
    listInvitation = => first @page.list.invitations

    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    assert.equal @page.confirmator.title, "Inv 1"
    assert.equal @page.confirmator.phone, "12341234"
    assert.equal @page.confirmator.confirmedGuestsCount, undefined
    assert.equal @page.list.totalConfirmedGuests(), 0

    @app.confirmator.confirmGuests(2)
    assert.notOk @app.confirmator
    assert.notOk @page.confirmator.title
    assert.ok listInvitation().isAssistanceConfirmed
    assert.equal listInvitation().confirmedGuestsCount, 2
    assert.equal @page.list.totalConfirmedGuests(), 2

    call = last @store.allFunctionCalls()
    assert.equal call.name, "updateRecord"
    assert.equal call.params, listInvitation()

  test "confirm without value", (assert) ->
    listInvitation = => first @page.list.invitations
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.confirmGuests("")
    assert.equal @page.confirmator.title, "Inv 1"
    assert.equal @page.confirmator.phone, "12341234"
    assert.equal @page.confirmator.confirmedGuestsCount, undefined
    assert.equal @page.list.totalConfirmedGuests(), 0

  test "update without value", (assert) ->
    listInvitation = => first @page.list.invitations
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.confirmGuests(2)
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.confirmGuests("")
    assert.equal @page.confirmator.title, "Inv 1"
    assert.equal @page.confirmator.phone, "12341234"
    assert.equal @page.confirmator.confirmedGuestsCount, 2

  test "cancel", (assert) ->
    listInvitation = => first @page.list.invitations
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.cancel()
    assert.notOk @app.confirmator
    assert.notOk @page.confirmator.title
    assert.notOk listInvitation().isAssistanceConfirmed
