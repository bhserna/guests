StoreSpy = require("./support/store_spy.coffee")
TestDisplay = require("./support/test_display.coffee")
addInvitation = require("./support/add_invitation.coffee")
{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]

module "Add guests by invitation", (hooks) ->
  hooks.beforeEach ->
    @store = new StoreSpy(new MemoryStore)
    @page = new TestDisplay
    @app = new GuestsApp(@store, @page)

  test "knows is a new invitation", (assert) ->
    invitation = @app.currentInvitation()
    assert.ok invitation.isNewInvitation

  test "on init is clean", (assert) ->
    invitation = @app.currentInvitation()
    assert.equal invitation.title, ""
    assert.equal invitation.guests.length, 0
    assert.equal invitation.phone, ""

  test "add invitation title", (assert) ->
    invitation = @app.addInvitationTitle("Serna Moreno")
    assert.equal invitation.title, "Serna Moreno"
    assert.notOk invitation.isEditingTitle

  test "turn on title edition", (assert) ->
    invitation = @app.addInvitationTitle("Serna Moreno")
    assert.notOk invitation.isEditingTitle
    invitation = @app.turnOnTitleEdition()
    assert.ok invitation.isEditingTitle

  test "edit title", (assert) ->
    @app.addInvitationTitle("Serna More")
    invitation = @app.addInvitationTitle("Serna Moreno")
    assert.equal invitation.title, "Serna Moreno"
    assert.notOk invitation.isEditingTitle

  test "add a guest", (assert) ->
    invitation = @app.addGuest(name: "Benito Serna")
    assert.equal invitation.guests.length, 1
    assert.equal first(invitation.guests).name, "Benito Serna"

  test "turn on guest edition", (assert) ->
    invitation = @app.addGuest(name: "Benito")
    assert.notOk (guest = first(invitation.guests)).isEditing
    invitation = @app.turnOnGuestEdition(guest.id)
    assert.ok first(invitation.guests).isEditing

  test "edit guest", (assert) ->
    invitation = @app.addGuest(name: "Benito")
    invitation = @app.updateGuest(first(invitation.guests).id, name: "Benito Serna")
    assert.equal first(invitation.guests).name, "Benito Serna"

  test "delete guest from the new invitation", (assert) ->
    invitation = @app.addGuest(name: "Benito")
    invitation = @app.deleteGuest(first(invitation.guests).id)
    assert.equal invitation.guests.length, 0

  test "add more than one guests to the invitation", (assert) ->
    @app.addGuest(name: "Benito Serna")
    invitation = @app.addGuest(name: "Maripaz Moreno")
    assert.equal invitation.guests.length, 2
    assert.equal second(invitation.guests).name, "Maripaz Moreno"

  test "turn on phone edition", (assert) ->
    invitation = @app.currentInvitation()
    assert.notOk invitation.isEditingPhone
    invitation = @app.turnOnPhoneEdition()
    assert.ok invitation.isEditingPhone

  test "add phone", (assert) ->
    invitation = @app.updatePhone("12341234")
    assert.notOk invitation.isEditingPhone
    assert.equal invitation.phone, "12341234"

  test "turn on email edition", (assert) ->
    invitation = @app.currentInvitation()
    assert.notOk invitation.isEditingEmail
    invitation = @app.turnOnEmailEdition()
    assert.ok invitation.isEditingEmail

  test "add email", (assert) ->
    invitation = @app.updateEmail("b@e.com")
    assert.notOk invitation.isEditingEmail
    assert.equal invitation.email, "b@e.com"

  test "save starts a new invitation", (assert) ->
    @app.addInvitationTitle("Serna Moreno")
    @app.addGuest("Benito Serna")
    @app.updatePhone("1234")
    @app.updateEmail("b@g")
    @app.saveInvitation()
    invitation = @app.currentInvitation()
    assert.equal invitation.title, ""
    assert.equal invitation.guests.length, 0
    assert.equal invitation.phone, ""
    assert.equal invitation.email, null

  test "save, saves the record", (assert) ->
    @app.addInvitationTitle("Serna Moreno")
    @app.addGuest(name: "Benito Serna")
    @app.addGuest(name: "Maripaz Moreno")
    @app.updatePhone("1234")
    @app.updateEmail("b@g.com")
    @app.saveInvitation()
    call = first @store.allFunctionCalls()
    assert.equal call.name, "saveRecord"
    record = call.params
    assert.equal record.title, "Serna Moreno"
    assert.equal first(record.guests).name, "Benito Serna"
    assert.equal second(record.guests).name, "Maripaz Moreno"
    assert.equal record.phone, "1234"
    assert.equal record.email, "b@g.com"

