{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]

module "Add guests by invitation", (hooks) ->
  hooks.beforeEach ->
    store = new MemoryStore
    @app = new GuestsApp(store)
    @list = @app.invitationsList
    @new = @app.newInvitation

  test "on init", (assert) ->
    assert.equal @new.title, ""
    assert.equal @new.guests.length, 0
    assert.equal @list.invitations.length, 0

  test "sets the invitation title", (assert) ->
    @new.addTitle("Serna Moreno")
    assert.equal @new.title, "Serna Moreno"

  test "sets the invitation title and then edit it", (assert) ->
    assert.ok @new.isEditingTitle

    @new.addTitle("Serna More")
    assert.notOk @new.isEditingTitle
    assert.equal @new.title, "Serna More"

    @new.turnOnTitleEdition()
    assert.ok @new.isEditingTitle
    assert.equal @new.title, "Serna More"

    @new.addTitle("Serna Moreno")
    assert.notOk @new.isEditingTitle
    assert.equal @new.title, "Serna Moreno"

  test "adds a guest to the current list", (assert) ->
    @new.addTitle("Serna Moreno")
    @new.addGuest(name: "Benito Serna")
    assert.equal @new.guests.length, 1
    assert.equal first(@new.guests).name, "Benito Serna"

  test "edit guest from the current list", (assert) ->
    @new.addTitle("Serna Moreno")
    @new.addGuest(name: "Benito")
    getGuest = => first(@new.guests)
    assert.notOk getGuest().isEditing

    @new.turnOnGuestEdition(getGuest().id)
    assert.ok getGuest().isEditing

    @new.updateGuest(getGuest().id, name: "Benito Serna")
    assert.equal getGuest().name, "Benito Serna"

  test "add more than one guests to the current list", (assert) ->
    @new.addTitle("Serna Moreno")
    @new.addGuest(name: "Benito Serna")
    @new.addGuest(name: "Maripaz Moreno")
    assert.equal @new.guests.length, 2
    assert.equal second(@new.guests).name, "Maripaz Moreno"

  test "commits the added guests to the store", (assert) ->
    @new.addTitle("Serna Moreno")
    @new.addGuest(name: "Benito Serna")
    @new.addGuest(name: "Maripaz Moreno")
    @new.commit()
    assert.equal @list.invitations.length, 1

    invitation = first @list.invitations
    assert.equal invitation.title, "Serna Moreno"
    assert.equal first(invitation.guests).name, "Benito Serna"
    assert.equal second(invitation.guests).name, "Maripaz Moreno"

# module "Edit invitation", (hooks) ->
#   addInvitation = (adder, title, guests) ->
#     adder.addInvitationTitle(title)
#     adder.addGuest(name: guest) for guest in guests
#     adder.commit()
#
#   hooks.beforeEach ->
#     store = new MemoryStore
#     @list = new ShowAllInvitations(store)
#     @adder = new AddGuestsByInvitation(store)
#     @editor = new EditInvitationWithGuests(store)
#     addInvitation(@adder, "Serna Moreno", ["guest1", "guest2"])
#
#   test "on init it is not active", (assert) ->
#     assert.notOk @editor.isActive()
#
#   test "it can be activated for an invitation", (assert) ->
#     invitation = first @list.invitations()
#     @editor.activateForInvitationWithId(invitation.id)
#     assert.ok @editor.isActive()
