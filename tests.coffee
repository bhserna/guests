{test, module} = QUnit
first = (list) -> list[0]
second = (list) -> list[1]

class TestDisplay
  editor: {}
  list: {}
  confirmator: {}

  renderEditor: (data) ->
    @editor = data

  renderList: (data) ->
    @list = data

  renderConfirmator: (data) ->
    @confirmator = data

  removeConfirmator: ->
    @confirmator = {}

addInvitation = (app, title, guests, phone, email) ->
  app.addInvitation()
  app.editor.addTitle(title)
  app.editor.addGuest(name: guest) for guest in guests
  app.editor.updatePhone(phone)
  app.editor.updateEmail(email)
  app.editor.commit()

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

  test "add phone", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    assert.notOk @page.editor.isEditingPhone

    @app.editor.turnOnPhoneEdition()
    assert.ok @page.editor.isEditingPhone

    @app.editor.updatePhone("12341234")
    assert.notOk @page.editor.isEditingPhone
    assert.equal @page.editor.phone, "12341234"

  test "commits the added phone to the store", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.turnOnPhoneEdition()
    @app.editor.updatePhone("12341234")
    @app.editor.commit()
    invitation = first @page.list.invitations

    assert.equal @page.list.invitations.length, 1
    assert.equal invitation.phone, "12341234"

  test "add email", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    assert.notOk @page.editor.isEditingEmail

    @app.editor.turnOnEmailEdition()
    assert.ok @page.editor.isEditingEmail

    @app.editor.updateEmail("b@e.com")
    assert.notOk @page.editor.isEditingEmail
    assert.equal @page.editor.email, "b@e.com"

  test "commits the added email to the store", (assert) ->
    @app.editor.addTitle("Serna Moreno")
    @app.editor.turnOnEmailEdition()
    @app.editor.updateEmail("a@b.com")
    @app.editor.commit()
    invitation = first @page.list.invitations

    assert.equal @page.list.invitations.length, 1
    assert.equal invitation.email, "a@b.com"

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
  hooks.beforeEach ->
    store = new MemoryStore
    @page = new TestDisplay
    @app = new GuestsApp(store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"])

  test "removes the invitation", (assert) ->
    invitation = first @page.list.invitations
    @app.list.deleteInvitation(invitation.id)
    assert.equal @page.list.invitations.length, 0

module "Show invitations list", (hooks) ->
  hooks.beforeEach ->
    store = new MemoryStore
    @page = new TestDisplay
    @app = new GuestsApp(store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "23452345", "a@b.com")
    addInvitation(@app, "Inv 2", ["guest1", "guest2", "guest3"])
    addInvitation(@app, "Inv 3", ["guest1"])

  test "show title", (assert) ->
    invitation = first @page.list.invitations
    assert.equal invitation.title, "Inv 1"

  test "has the guests names", (assert) ->
    invitation = first @page.list.invitations
    guests = invitation.guests
    assert.equal first(guests).name, "guest1"
    assert.equal second(guests).name, "guest2"

  test "has the guests count", (assert) ->
    invitation = first @page.list.invitations
    assert.equal invitation.guests.length, 2

  test "has phone", (assert) ->
    invitation = first @page.list.invitations
    assert.equal invitation.phone, "23452345"

  test "has email", (assert) ->
    invitation = first @page.list.invitations
    assert.equal invitation.email, "a@b.com"

  test "has the total invitations count", (assert) ->
    assert.equal @page.list.invitations.length, 3

  test "has the total guests", (assert) ->
    assert.equal @page.list.totalGuests(), 6

    invitation = first @page.list.invitations
    @app.list.deleteInvitation(invitation.id)
    assert.equal @page.list.totalGuests(), 4

    invitation = first @page.list.invitations
    @app.list.deleteInvitation(invitation.id)
    assert.equal @page.list.totalGuests(), 1

    invitation = first @page.list.invitations
    @app.list.deleteInvitation(invitation.id)
    assert.equal @page.list.totalGuests(), 0

module "Confirm invitation delivery", (hooks) ->
  hooks.beforeEach ->
    store = new MemoryStore
    @page = new TestDisplay
    @app = new GuestsApp(store, @page)
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

module "Confirm invitation invitation assistance", (hooks) ->
  hooks.beforeEach ->
    store = new MemoryStore
    @page = new TestDisplay
    @app = new GuestsApp(store, @page)
    addInvitation(@app, "Inv 1", ["guest1", "guest2"], "12341234")

  test "unstarted", (assert) ->
    listInvitation = => first @page.list.invitations
    assert.notOk @app.confirmator
    assert.notOk @page.confirmator.title
    assert.notOk listInvitation().isAssistanceConfirmed
    assert.equal @page.list.totalConfirmedGuests(), 0

  test "confirm", (assert) ->
    listInvitation = => first @page.list.invitations

    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    assert.equal @page.confirmator.title, "Inv 1"
    assert.equal @page.confirmator.phone, "12341234"
    assert.equal @page.confirmator.confirmedGuestsCount, undefined
    assert.equal @page.list.totalConfirmedGuests(), 0

    @app.confirmator.confirmGuests(2)
    assert.notOk @app.confirmator
    assert.notOk @page.confirmator.title
    assert.ok listInvitation().isAssistanceConfirmed
    assert.equal listInvitation().confirmedGuestsCount, 2
    assert.equal @page.list.totalConfirmedGuests(), 2

  test "confirm without value", (assert) ->
    listInvitation = => first @page.list.invitations
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.confirmGuests("")
    assert.equal @page.confirmator.title, "Inv 1"
    assert.equal @page.confirmator.phone, "12341234"
    assert.equal @page.confirmator.confirmedGuestsCount, undefined
    assert.equal @page.list.totalConfirmedGuests(), 0

  test "update without value", (assert) ->
    listInvitation = => first @page.list.invitations
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.confirmGuests(2)
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.confirmGuests("")
    assert.equal @page.confirmator.title, "Inv 1"
    assert.equal @page.confirmator.phone, "12341234"
    assert.equal @page.confirmator.confirmedGuestsCount, 2

  test "cancel", (assert) ->
    listInvitation = => first @page.list.invitations
    @app.list.startInvitationAssistanceConfirmation(listInvitation().id)
    @app.confirmator.cancel()
    assert.notOk @app.confirmator
    assert.notOk @page.confirmator.title
    assert.notOk listInvitation().isAssistanceConfirmed
