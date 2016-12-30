{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]

module "Add guests by invitation", (hooks) ->
  hooks.beforeEach ->
    store = new MemoryStore
    @adder = new AddGuestsByInvitation(store)
    @list = new ShowAllInvitations(store)

  test "on init", (assert) ->
    assert.equal @adder.invitationTitle(), ""
    assert.equal @adder.addedGuests().length, 0
    assert.equal @list.invitations().length, 0

  test "sets the invitation title", (assert) ->
    @adder.addInvitationTitle("Serna Moreno")
    assert.equal @adder.invitationTitle(), "Serna Moreno"

  test "sets the invitation title and then edit it", (assert) ->
    assert.ok @adder.isEditingInvitationTitle()

    @adder.addInvitationTitle("Serna More")
    assert.notOk @adder.isEditingInvitationTitle()
    assert.equal @adder.invitationTitle(), "Serna More"

    @adder.editInvitationTitle()
    assert.ok @adder.isEditingInvitationTitle()
    assert.equal @adder.invitationTitle(), "Serna More"

    @adder.addInvitationTitle("Serna Moreno")
    assert.notOk @adder.isEditingInvitationTitle()
    assert.equal @adder.invitationTitle(), "Serna Moreno"

  test "adds a guest to the current list", (assert) ->
    @adder.addInvitationTitle("Serna Moreno")
    @adder.addGuest(name: "Benito Serna")
    assert.equal @adder.addedGuests().length, 1
    assert.equal first(@adder.addedGuests()).name, "Benito Serna"

  test "edit guest from the current list", (assert) ->
    @adder.addInvitationTitle("Serna Moreno")
    @adder.addGuest(name: "Benito")
    getGuest = => first(@adder.addedGuests())
    assert.notOk getGuest().isEditing

    @adder.editGuest(getGuest().id)
    assert.ok getGuest().isEditing

    @adder.updateGuest(getGuest().id, name: "Benito Serna")
    assert.equal getGuest().name, "Benito Serna"

  test "add more than one guests to the current list", (assert) ->
    @adder.addInvitationTitle("Serna Moreno")
    @adder.addGuest(name: "Benito Serna")
    @adder.addGuest(name: "Maripaz Moreno")
    assert.equal @adder.addedGuests().length, 2
    assert.equal second(@adder.addedGuests()).name, "Maripaz Moreno"

  test "commits the added guests to the store", (assert) ->
    @adder.addInvitationTitle("Serna Moreno")
    @adder.addGuest(name: "Benito Serna")
    @adder.addGuest(name: "Maripaz Moreno")
    @adder.commit()
    assert.equal @list.invitations().length, 1

    invitation = first @list.invitations()
    assert.equal invitation.title, "Serna Moreno"
    assert.equal first(invitation.guests).name, "Benito Serna"
    assert.equal second(invitation.guests).name, "Maripaz Moreno"
