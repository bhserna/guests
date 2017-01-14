class Guest
  constructor: ({@id, @name})->

class Invitation
  constructor: ({
    @id, @title, @guests, @phone, @email, @isDelivered,
    @confirmedGuestsCount, @isAssistanceConfirmed}) ->

class EditableInvitation extends Invitation
  constructor: (opts = {}) ->
    super(opts)
    @title = opts.title or ""
    @phone = opts.phone or ""
    @guests = (new EditableGuest(guest) for guest in (opts.guests or []))
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

class DeliverableInvitation extends Invitation
  confirmDelivery: ->
    @isDelivered = true

  unconfirmDelivery: ->
    @isDelivered = false

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
    reduce((acc, count) -> acc + count).
    value() or 0

  totalDeliveredInvitations: ->
    _.filter(@invitations, (invitation) -> invitation.isDelivered).length

  totalConfirmedGuests: ->
    _.chain(@invitations).
    map((invitation) -> parseInt(invitation.confirmedGuestsCount)).
    reject((count) -> isNaN(count)).
    reduce((acc, count) -> acc + count).
    value() or 0

  confirmInvitationDelivery: (id) ->
    invitation = new DeliverableInvitation(@findInvitation(id))
    invitation.confirmDelivery()
    @updateInvitation(invitation)

  unconfirmInvitationDelivery: (id) ->
    invitation = new DeliverableInvitation(@findInvitation(id))
    invitation.unconfirmDelivery()
    @updateInvitation(invitation)

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

  startInvitationAssistanceConfirmation: (invitation) ->
    @confirmator = new AssistanceConfirmationControl(invitation, @, @display)

  commitInvitationConfirmation: (invitation) ->
    @list.updateInvitation(invitation)
    @confirmator = undefined

  cancelInvitationConfirmation: (invitation) ->
    @confirmator = undefined

class AssistanceConfirmationControl
  constructor: (invitation, @app, @display) ->
    @invitation = new AssistanceConfirmableInvitation(invitation)
    @display.renderConfirmator(@invitation)

  confirmGuests: (count) ->
    if @invitation.validGuestsConfirmationCount(count)
      @invitation.setConfirmedGuests(count)
      @app.commitInvitationConfirmation(@invitation)
      @display.removeConfirmator()

  cancel: ->
    @app.cancelInvitationConfirmation(@invitation)
    @display.removeConfirmator()

  class AssistanceConfirmableInvitation extends Invitation
    validGuestsConfirmationCount: (count) ->
      parseInt(count) >= 0

    setConfirmedGuests: (count) ->
      count = parseInt(count)
      @confirmedGuestsCount = count
      @isAssistanceConfirmed = true

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

  confirmInvitationDelivery: (id) ->
    @list.confirmInvitationDelivery(id)
    @updateStore()
    @updateDisplay()

  unconfirmInvitationDelivery: (id) ->
    @list.unconfirmInvitationDelivery(id)
    @updateStore()
    @updateDisplay()

  startInvitationAssistanceConfirmation: (id) ->
    @app.startInvitationAssistanceConfirmation(@findInvitation(id))

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
