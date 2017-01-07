{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]

class TestDisplay
  editor: {}
  list: {}

  renderEditor: (data) ->
    @editor = data

  renderList: (data) ->
    @list = data

module "Add guests by invitation", (hooks) ->
  hooks.beforeEach ->
    store = new MemoryStore
    @page = new TestDisplay
    @app = new GuestsApp(store, @page)
    @editor = @app.addInvitation()

  test "knows is a new invitation", (assert) ->
    assert.ok @page.editor.isNewInvitation

  test "on init is clean", (assert) ->
    assert.equal @page.editor.title, ""
    assert.equal @page.editor.guests.length, 0
    assert.equal @page.list.invitations.length, 0

  test "sets the invitation title", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    assert.equal @page.editor.title, "Serna Moreno"

  test "sets the invitation title and then edit it", (assert) ->
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

  test "adds a guest to the current list", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito Serna")
    assert.equal @page.editor.guests.length, 1
    assert.equal first(@page.editor.guests).name, "Benito Serna"

  test "edit guest from the current list", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito")
    getGuest = => first(@page.editor.guests)
    assert.notOk getGuest().isEditing

    @app.editor.turnOnGuestEdition(getGuest().id)
    assert.ok getGuest().isEditing

    @app.editor.updateGuest(getGuest().id, name: "Benito Serna")
    assert.equal getGuest().name, "Benito Serna"

  test "delete guest from the current list", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito")
    getGuest = => first(@page.editor.guests)

    @app.editor.deleteGuest(getGuest().id)
    assert.equal @page.editor.guests.length, 0

  test "add more than one guests to the current list", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito Serna")
    @app.editor.addGuest(name: "Maripaz Moreno")
    assert.equal @page.editor.guests.length, 2
    assert.equal second(@page.editor.guests).name, "Maripaz Moreno"

  test "commits the added guests to the store", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito Serna")
    @app.editor.addGuest(name: "Maripaz Moreno")
    @app.editor.commit()
    assert.equal @page.list.invitations.length, 1

    invitation = first @page.list.invitations
    assert.equal invitation.title, "Serna Moreno"
    assert.equal first(invitation.guests).name, "Benito Serna"
    assert.equal second(invitation.guests).name, "Maripaz Moreno"

  test "after commits the editor is cleaned", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.addGuest(name: "Benito Serna")
    @app.editor.addGuest(name: "Maripaz Moreno")
    @app.editor.commit()
    assert.equal @page.editor.title, ""
    assert.equal @page.editor.guests.length, 0

module "Edit invitation", (hooks) ->
  addInvitation = (app, title, guests) ->
    app.addInvitation()
    app.editor.addTitle(title)
    app.editor.addGuest(name: guest) for guest in guests
    app.editor.commit()

  hooks.beforeEach ->
    store = new MemoryStore
    @page = new TestDisplay
    @app = new GuestsApp(store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"])

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

module "Delete invitation", (hooks) ->
  addInvitation = (app, title, guests) ->
    app.addInvitation()
    app.editor.addTitle(title)
    app.editor.addGuest(name: guest) for guest in guests
    app.editor.commit()

  hooks.beforeEach ->
    store = new MemoryStore
    @page = new TestDisplay
    @app = new GuestsApp(store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"])

  test "removes the invitation", (assert) ->
    invitation = first @page.list.invitations
    @app.list.deleteInvitation(invitation.id)
    assert.equal @page.list.invitations.length, 0
