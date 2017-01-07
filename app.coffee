class Guest
  constructor: ({@id, @name})->

class Invitation
  constructor: ({@id, @title, @guests, @phone, @email})->

class EditableInvitation
  constructor: (opts = {}) ->
    @id = opts.id
    @title = opts.title or ""
    @guests = (new EditableGuest(guest) for guest in (opts.guests or []))
    @phone = ""
    @isNewInvitation = !@id
    @isEditingPhone = false
    @isEditingEmail = false
    @turnOnTitleEdition() unless @title

  addTitle: (title) ->
    @title = title
    @isEditingTitle = false

  turnOnTitleEdition: ->
    @isEditingTitle = true

  addGuest: (attrs) ->
    attrs.id = @guests.length + 1
    guest = new EditableGuest(attrs)
    @guests.push(guest)

  turnOnGuestEdition: (id) ->
    guest = @findGuest(id)
    guest.toEditionMode()

  updateGuest: (id, attrs) ->
    guest = @findGuest(id)
    guest.setName(attrs.name)
    guest.turnOffEditionMode()

  deleteGuest: (id) ->
    @guests = (guest for guest in @guests when guest.id isnt id)

  findGuest: (id) ->
    (guest for guest in @guests when guest.id is id)[0]

  turnOnPhoneEdition: ->
    @isEditingPhone = true

  updatePhone: (phone) ->
    @phone = phone
    @isEditingPhone = false

  turnOnEmailEdition: ->
    @isEditingEmail = true

  updateEmail: (email) ->
    @email = email
    @isEditingEmail = false

class EditableGuest extends Guest
  isEditing: false

  setName: (name) ->
    @name = name

  toEditionMode: ->
    @isEditing = true

  turnOffEditionMode: ->
    @isEditing = false

class InvitationsList
  constructor: (@invitations) ->

  findInvitation: (id) ->
    _.findWhere(@invitations, id: id)

  addInvitation: (invitation) ->
    invitation.id = @invitations.length + 1
    invitation = @buildInvitation(invitation)
    @invitations.push(invitation)

  updateInvitation: (invitation) ->
    byId = _.indexBy(@invitations, "id")
    byId[invitation.id] = @buildInvitation(invitation)
    @invitations = _.values(byId)

  deleteInvitation: (id) ->
    @invitations = _.reject(@invitations, (invitation) -> invitation.id is id)

  totalGuests: ->
    _.chain(@invitations).
    map((invitation) -> invitation.guests.length).
    reduce((acc, count) -> acc + count)

  buildInvitation: (attrs) ->
    attrs.guests = (new Guest(guest) for guest in attrs.guests)
    invitation = new Invitation(attrs)

class window.GuestsApp
  constructor: (@store, @display) ->
    @list = new InvitationsListControl(@, @store, @display)
    @addInvitation()

  addInvitation: ->
    @editor = new NewInvitationControl(new EditableInvitation, @, @display)

  editInvitation: (invitation) ->
    @editor = new EditInvitationControl(new EditableInvitation(invitation), @, @display)

  commitAddition: (invitation) ->
    @list.addInvitation(invitation)
    @addInvitation()

  commitEdition: (invitation)->
    @list.updateInvitation(invitation)
    @addInvitation()

class InvitationsListControl
  constructor: (@app, @store, @display) ->
    @invitations = @store.fetchRecords()
    @list = new InvitationsList(@invitations)
    @updateDisplay()

  updateDisplay: ->
    @display.renderList(@list)

  updateStore: ->
    @store.updateRecords(@list.invitations)

  findInvitation: (id) ->
    @list.findInvitation(id)

  deleteInvitation: (id) ->
    @list.deleteInvitation(id)
    @updateStore()
    @updateDisplay()

  addInvitation: (title, guests) ->
    @list.addInvitation(title, guests)
    @updateStore()
    @updateDisplay()

  editInvitation: (id) ->
    @app.editInvitation(@findInvitation(id))

  updateInvitation: (id, title, guests) ->
    @list.updateInvitation(id, title, guests)
    @updateStore()
    @updateDisplay()

class EditInvitationControl
  constructor: (@invitation, @app, @display) ->
    @updateDisplay()

  updateDisplay: ->
    @display.renderEditor(@invitation)

  addTitle: (title) ->
    @invitation.addTitle(title)
    @updateDisplay()

  turnOnTitleEdition: ->
    @invitation.turnOnTitleEdition()
    @updateDisplay()

  addGuest: (attrs) ->
    @invitation.addGuest(attrs)
    @updateDisplay()

  turnOnGuestEdition: (id) ->
    @invitation.turnOnGuestEdition(id)
    @updateDisplay()

  updateGuest: (id, attrs) ->
    @invitation.updateGuest(id, attrs)
    @updateDisplay()

  deleteGuest: (id) ->
    @invitation.deleteGuest(id)
    @updateDisplay()

  turnOnPhoneEdition: ->
    @invitation.turnOnPhoneEdition()
    @updateDisplay()

  updatePhone: (phone) ->
    @invitation.updatePhone(phone)
    @updateDisplay()

  turnOnEmailEdition: ->
    @invitation.turnOnEmailEdition()
    @updateDisplay()

  updateEmail: (email) ->
    @invitation.updateEmail(email)
    @updateDisplay()

  commit: ->
    @app.commitEdition(@invitation)

class NewInvitationControl extends EditInvitationControl
  commit: -> @app.commitAddition(@invitation)

class window.MemoryStore
  constructor: (@records = []) ->
  fetchRecords: -> @records
  updateRecords: (records) -> @records = records

window.LocalStore =
  fetchRecords: ->
     JSON.parse(localStorage.invitations || "[]")

  updateRecords: (records) ->
    localStorage.invitations = JSON.stringify(records)
