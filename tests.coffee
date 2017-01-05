{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]

module "Add guests by invitation", (hooks) ->
  hooks.beforeEach ->
    store = new MemoryStore
    @app = new GuestsApp(store)
    @list = @app.invitationsList
    @editor = @app.invitationEditor
    @app.addInvitation()

  test "editor is adding invitation", (assert) ->
    assert.ok @editor.isAddingInvitation
    assert.notOk @editor.isEditingInvitation

  test "on init is clean", (assert) ->
    assert.equal @editor.title, ""
    assert.equal @editor.guests.length, 0
    assert.equal @list.invitations.length, 0

  test "sets the invitation title", (assert) ->
    @editor.addTitle("Serna Moreno")
    assert.equal @editor.title, "Serna Moreno"

  test "sets the invitation title and then edit it", (assert) ->
    assert.ok @editor.isEditingTitle

    @editor.addTitle("Serna More")
    assert.notOk @editor.isEditingTitle
    assert.equal @editor.title, "Serna More"

    @editor.turnOnTitleEdition()
    assert.ok @editor.isEditingTitle
    assert.equal @editor.title, "Serna More"

    @editor.addTitle("Serna Moreno")
    assert.notOk @editor.isEditingTitle
    assert.equal @editor.title, "Serna Moreno"

  test "adds a guest to the current list", (assert) ->
    @editor.addTitle("Serna Moreno")
    @editor.addGuest(name: "Benito Serna")
    assert.equal @editor.guests.length, 1
    assert.equal first(@editor.guests).name, "Benito Serna"

  test "edit guest from the current list", (assert) ->
    @editor.addTitle("Serna Moreno")
    @editor.addGuest(name: "Benito")
    getGuest = => first(@editor.guests)
    assert.notOk getGuest().isEditing

    @editor.turnOnGuestEdition(getGuest().id)
    assert.ok getGuest().isEditing

    @editor.updateGuest(getGuest().id, name: "Benito Serna")
    assert.equal getGuest().name, "Benito Serna"

  test "add more than one guests to the current list", (assert) ->
    @editor.addTitle("Serna Moreno")
    @editor.addGuest(name: "Benito Serna")
    @editor.addGuest(name: "Maripaz Moreno")
    assert.equal @editor.guests.length, 2
    assert.equal second(@editor.guests).name, "Maripaz Moreno"

  test "commits the added guests to the store", (assert) ->
    @editor.addTitle("Serna Moreno")
    @editor.addGuest(name: "Benito Serna")
    @editor.addGuest(name: "Maripaz Moreno")
    @editor.commit()
    assert.equal @list.invitations.length, 1

    invitation = first @list.invitations
    assert.equal invitation.title, "Serna Moreno"
    assert.equal first(invitation.guests).name, "Benito Serna"
    assert.equal second(invitation.guests).name, "Maripaz Moreno"

  test "after commits the editor is cleaned", (assert) ->
    @editor.addTitle("Serna Moreno")
    @editor.addGuest(name: "Benito Serna")
    @editor.addGuest(name: "Maripaz Moreno")
    @editor.commit()
    assert.equal @editor.title, ""
    assert.equal @editor.guests.length, 0

module "Edit invitation", (hooks) ->
  addInvitation = (app, title, guests) ->
    editor = app.invitationEditor
    app.addInvitation()
    editor.addTitle(title)
    editor.addGuest(name: guest) for guest in guests
    editor.commit()

  hooks.beforeEach ->
    store = new MemoryStore
    @app = new GuestsApp(store)
    @list = @app.invitationsList
    @editor = @app.invitationEditor
    addInvitation(@app, "Inv 1", ["guest1", "guest2"])

  test "is not active by default", (assert) ->
    assert.ok @editor.isAddingInvitation
    assert.notOk @editor.isEditingInvitation

  test "it can be activated for an invitation", (assert) ->
    invitation = first @list.invitations
    @app.editInvitationWithId(invitation.id)
    assert.notOk @editor.isAddingInvitation
    assert.ok @editor.isEditingInvitation

  test "it has the information of the invitation to edit", (assert) ->
    invitation = first @list.invitations
    @app.editInvitationWithId(invitation.id)
    assert.equal @editor.title, "Inv 1"
    assert.equal first(@editor.guests).name, "guest1"
    assert.equal second(@editor.guests).name, "guest2"

  test "after commit it updates the invitation", (assert) ->
    invitation = first @list.invitations
    @app.editInvitationWithId(invitation.id)
    @editor.addTitle("Serna Moreno")
    @editor.updateGuest(first(@editor.guests).id, name: "Benito Serna")
    @editor.updateGuest(second(@editor.guests).id, name: "Maripaz Moreno")
    @editor.commit()

    assert.equal @list.invitations.length, 1
    invitation = first @list.invitations
    assert.equal invitation.title, "Serna Moreno"
    assert.equal first(invitation.guests).name, "Benito Serna"
    assert.equal second(invitation.guests).name, "Maripaz Moreno"

  test "after commit it returns to adding invitation mode", (assert) ->
    invitation = first @list.invitations
    @app.editInvitationWithId(invitation.id)
    @editor.commit()
    assert.ok @editor.isAddingInvitation
    assert.notOk @editor.isEditingInvitation
