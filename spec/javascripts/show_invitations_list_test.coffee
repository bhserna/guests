_ = require("underscore")
StoreSpy = require("./support/store_spy.coffee")
TestDisplay = require("./support/test_display.coffee")
addInvitation = require("./support/add_invitation.coffee")
{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]
last = (list) -> _.last(list)

module "Show invitations list", (hooks) ->
  hooks.beforeEach ->
    @store = new StoreSpy(new MemoryStore)
    @page = new TestDisplay
    @app = new GuestsApp(@store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "23452345", "a@b.com")
    addInvitation(@app, "Inv 2", ["guest1", "guest2", "guest3"])
    addInvitation(@app, "Inv 3", ["guest1"])

  test "show title", (assert) ->
    invitation = first @app.getInvitations()
    assert.equal invitation.title, "Inv 1"

  test "has the guests names", (assert) ->
    invitation = first @app.getInvitations()
    guests = invitation.guests
    assert.equal first(guests).name, "guest1"
    assert.equal second(guests).name, "guest2"

  test "has the guests count", (assert) ->
    invitation = first @app.getInvitations()
    assert.equal invitation.guests.length, 2

  test "has phone", (assert) ->
    invitation = first @app.getInvitations()
    assert.equal invitation.phone, "23452345"

  test "has email", (assert) ->
    invitation = first @app.getInvitations()
    assert.equal invitation.email, "a@b.com"

  test "has the total invitations count", (assert) ->
    assert.equal @app.getInvitationsCount(), 3

  test "has the total guests", (assert) ->
    assert.equal @app.getTotalGuests(), 6

    invitation = first @app.getInvitations()
    @app.deleteInvitation(invitation.id)
    assert.equal @app.getTotalGuests(), 4

    invitation = first @app.getInvitations()
    @app.deleteInvitation(invitation.id)
    assert.equal @app.getTotalGuests(), 1

    invitation = first @app.getInvitations()
    @app.deleteInvitation(invitation.id)
    assert.equal @app.getTotalGuests(), 0

