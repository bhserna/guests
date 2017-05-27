_ = require("underscore")
StoreSpy = require("./support/store_spy.coffee")
TestDisplay = require("./support/test_display.coffee")
addInvitation = require("./support/add_invitation.coffee")

{test, module} = QUnit
first = (list) -> list[0]
last = (list) -> _.last(list)

module "Delete invitation", (hooks) ->
  hooks.beforeEach ->
    @store = new StoreSpy(new MemoryStore)
    @page = new TestDisplay
    @app = new GuestsApp(@store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"])

  test "removes the invitation", (assert) ->
    invitation = first @app.getInvitations()
    @app.deleteInvitation(invitation.id)
    assert.equal @app.getInvitationsCount(), 0

  test "removes the invitation in the store", (assert) ->
    invitation = first @app.getInvitations()
    @app.deleteInvitation(invitation.id)
    call = last @store.allFunctionCalls()
    assert.equal call.name, "deleteRecord"
    assert.equal call.params, invitation.id

