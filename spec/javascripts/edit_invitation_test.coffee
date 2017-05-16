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
    invitation = first @page.list.invitations
    @app.list.editInvitation(invitation.id)
    assert.notOk @page.editor.isNewInvitation

  test "it start with the title in non edition mode", (assert) ->
    invitation = first @page.list.invitations
    @app.list.editInvitation(invitation.id)
    assert.notOk @page.editor.isEditingTitle

  test "it has the information of the invitation to edit", (assert) ->
    invitation = first @page.list.invitations
    @app.list.editInvitation(invitation.id)
    assert.equal @page.editor.title, "Inv 1"
    assert.equal first(@page.editor.guests).name, "guest1"
    assert.equal second(@page.editor.guests).name, "guest2"
    assert.equal @page.editor.phone, "1234"
    assert.equal @page.editor.email, "b@g.com"

  test "after commit it updates the invitation", (assert) ->
    invitation = first @page.list.invitations
    @app.list.editInvitation(invitation.id)
    @app.editor.addTitle("Serna Moreno")
    @app.editor.updateGuest(first(@page.editor.guests).id, name: "Benito Serna")
    @app.editor.updateGuest(second(@page.editor.guests).id, name: "Maripaz Moreno")
    @app.editor.commit()

    assert.equal @page.list.invitations.length, 1
    invitation = first @page.list.invitations
    assert.equal invitation.title, "Serna Moreno"
    assert.equal first(invitation.guests).name, "Benito Serna"
    assert.equal second(invitation.guests).name, "Maripaz Moreno"

  test "after commit it updates the invitation in the store", (assert) ->
    invitation = first @page.list.invitations
    @app.list.editInvitation(invitation.id)
    @app.editor.addTitle("Serna Moreno")
    @app.editor.updateGuest(first(@page.editor.guests).id, name: "Benito Serna")
    @app.editor.updateGuest(second(@page.editor.guests).id, name: "Maripaz Moreno")
    @app.editor.commit()

    call = last @store.allFunctionCalls()
    assert.equal call.name, "updateRecord"
    invitation = call.params
    assert.equal invitation.title, "Serna Moreno"
    assert.equal first(invitation.guests).name, "Benito Serna"
    assert.equal second(invitation.guests).name, "Maripaz Moreno"

  test "after commit it returns to adding invitation mode", (assert) ->
    invitation = first @page.list.invitations
    @app.list.editInvitation(invitation.id)
    @app.editor.commit()
    assert.ok @page.editor.isNewInvitation

  test "after commits the editor is cleaned", (assert) ->
    invitation = first @page.list.invitations
    @app.list.editInvitation(invitation.id)
    @app.editor.commit()
    assert.equal @page.editor.title, ""
    assert.equal @page.editor.guests.length, 0

