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
    @app.addInvitation()

  test "knows is a new invitation", (assert) ->
    assert.ok @page.editor.isNewInvitation

  test "on init is clean", (assert) ->
    assert.equal @page.editor.title, ""
    assert.equal @page.editor.guests.length, 0
    assert.equal @page.list.invitations.length, 0

  test "set the invitation title", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    assert.equal @page.editor.title, "Serna Moreno"

  test "set the invitation title and then edit it", (assert) ->
    assert.ok @page.editor.isEditingTitle

    @app.editor.addTitle("Serna More")
    assert.notOk @page.editor.isEditingTitle
    assert.equal @page.editor.title, "Serna More"

    @app.editor.turnOnTitleEdition()
    assert.ok @page.editor.isEditingTitle
    assert.equal @page.editor.title, "Serna More"

    @app.editor.addTitle("Serna Moreno")
    assert.notOk @page.editor.isEditingTitle
    assert.equal @page.editor.title, "Serna Moreno"

  test "add a guest to the new invitation", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito Serna")
    assert.equal @page.editor.guests.length, 1
    assert.equal first(@page.editor.guests).name, "Benito Serna"

  test "edit guest from the invitation's guest list", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito")
    getGuest = => first(@page.editor.guests)
    assert.notOk getGuest().isEditing

    @app.editor.turnOnGuestEdition(getGuest().id)
    assert.ok getGuest().isEditing

    @app.editor.updateGuest(getGuest().id, name: "Benito Serna")
    assert.equal getGuest().name, "Benito Serna"

  test "delete guest from the new invitation", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito")
    getGuest = => first(@page.editor.guests)

    @app.editor.deleteGuest(getGuest().id)
    assert.equal @page.editor.guests.length, 0

  test "add more than one guests to the invitation", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito Serna")
    @app.editor.addGuest(name: "Maripaz Moreno")
    assert.equal @page.editor.guests.length, 2
    assert.equal second(@page.editor.guests).name, "Maripaz Moreno"

  test "add phone", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    assert.notOk @page.editor.isEditingPhone

    @app.editor.turnOnPhoneEdition()
    assert.ok @page.editor.isEditingPhone

    @app.editor.updatePhone("12341234")
    assert.notOk @page.editor.isEditingPhone
    assert.equal @page.editor.phone, "12341234"

  test "add email", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    assert.notOk @page.editor.isEditingEmail

    @app.editor.turnOnEmailEdition()
    assert.ok @page.editor.isEditingEmail

    @app.editor.updateEmail("b@e.com")
    assert.notOk @page.editor.isEditingEmail
    assert.equal @page.editor.email, "b@e.com"

  test "after commit the invitation is added to the list", (assert) ->
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "1234", "b@g.com")
    invitation = first @page.list.invitations
    assert.equal @page.list.invitations.length, 1
    assert.equal invitation.title, "Inv 1"
    assert.equal first(invitation.guests).name, "guest1"
    assert.equal second(invitation.guests).name, "guest2"
    assert.equal invitation.phone, "1234"
    assert.equal invitation.email, "b@g.com"

  test "after commits the editor is cleaned", (assert) ->
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "1234", "b@g.com")
    assert.equal @page.editor.title, ""
    assert.equal @page.editor.guests.length, 0

  test "after commit the invitation is sended to the store", (assert) ->
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "1234", "b@g.com")
    call = first @store.allFunctionCalls()
    assert.equal call.name, "saveRecord"

    invitation = call.params
    assert.equal invitation.title, "Inv 1"
    assert.equal first(invitation.guests).name, "guest1"
    assert.equal second(invitation.guests).name, "guest2"
    assert.equal invitation.phone, "1234"
    assert.equal invitation.email, "b@g.com"

