_ = require("underscore")
StoreSpy = require("./support/store_spy.coffee")
TestDisplay = require("./support/test_display.coffee")
addInvitation = require("./support/add_invitation.coffee")

{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]
last = (list) -> _.last(list)

module "Confirm invitation delivery", (hooks) ->
  hooks.beforeEach ->
    @store = new StoreSpy(new MemoryStore)
    @page = new TestDisplay
    @app = new GuestsApp(@store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"])
    addInvitation(@app, "Inv 2", ["guest1", "guest2"])
    addInvitation(@app, "Inv 3", ["guest1", "guest2"])

  test "confirm", (assert) ->
    invitation = => first @page.list.invitations
    assert.notOk invitation().isDelivered
    assert.equal @page.list.totalDeliveredInvitations(), 0

    @app.list.confirmInvitationDelivery(invitation().id)
    assert.ok invitation().isDelivered
    assert.equal @page.list.totalDeliveredInvitations(), 1

    call = last @store.allFunctionCalls()
    assert.equal call.name, "updateRecord"
    assert.equal call.params, invitation()

  test "undo", (assert) ->
    invitation = => first @page.list.invitations
    assert.notOk invitation().isDelivered
    assert.equal @page.list.totalDeliveredInvitations(), 0

    @app.list.confirmInvitationDelivery(invitation().id)
    assert.ok invitation().isDelivered
    assert.equal @page.list.totalDeliveredInvitations(), 1

    @app.list.unconfirmInvitationDelivery(invitation().id)
    assert.notOk invitation().isDelivered
    assert.equal @page.list.totalDeliveredInvitations(), 0

    call = last @store.allFunctionCalls()
    assert.equal call.name, "updateRecord"
    assert.equal call.params, invitation()

