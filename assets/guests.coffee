_ = require("underscore")

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
    @

  turnOnTitleEdition: ->
    @isEditingTitle = true
    @

  addGuest: (attrs) ->
    attrs.id = @guests.length + 1
    guest = new EditableGuest(attrs)
    @guests.push(guest)
    @

  turnOnGuestEdition: (id) ->
    guest = @findGuest(id)
    guest.toEditionMode()
    @

  updateGuest: (id, attrs) ->
    guest = @findGuest(id)
    guest.setName(attrs.name)
    guest.turnOffEditionMode()
    @

  deleteGuest: (id) ->
    @guests = (guest for guest in @guests when guest.id isnt id)
    @

  findGuest: (id) ->
    (guest for guest in @guests when guest.id is id)[0]

  turnOnPhoneEdition: ->
    @isEditingPhone = true
    @

  updatePhone: (phone) ->
    @phone = phone
    @isEditingPhone = false
    @

  turnOnEmailEdition: ->
    @isEditingEmail = true
    @

  updateEmail: (email) ->
    @email = email
    @isEditingEmail = false
    @

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
  constructor: (records) ->
    @invitations = (@buildInvitation(record) for record in records)

  findInvitation: (id) ->
    _.findWhere(@invitations, id: id)

  addInvitation: (invitation) ->
    invitation.id = @invitations.length + 1
    invitation = @buildInvitation(invitation)
    @invitations.push(invitation)
    invitation

  updateInvitation: (invitation) ->
    byId = _.indexBy(@invitations, "id")
    invitation = @buildInvitation(invitation)
    byId[invitation.id] = invitation
    @invitations = _.values(byId)
    invitation

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
  constructor: (@store) ->
    @list = new InvitationsListControl(@, @store)
    @invitation = new EditableInvitation()

  addInvitation: ->

  currentInvitation: ->
    @invitation

  editInvitation: (id) ->
    @invitation = new EditableInvitation(@store.find(id))

  addInvitationTitle: (title) ->
    @invitation.addTitle(title)

  turnOnTitleEdition: ->
    @invitation.turnOnTitleEdition()

  addGuest: (attrs) ->
    @invitation.addGuest(attrs)

  turnOnGuestEdition: (guestId) ->
    @invitation.turnOnGuestEdition(guestId)

  updateGuest: (guestId, attrs) ->
    @invitation.updateGuest(guestId, attrs)

  deleteGuest: (guestId) ->
    @invitation.deleteGuest(guestId)

  turnOnPhoneEdition: ->
    @invitation.turnOnPhoneEdition()

  updatePhone: (phone) ->
    @invitation.updatePhone(phone)

  turnOnEmailEdition: ->
    @invitation.turnOnEmailEdition()

  updateEmail: (email) ->
    @invitation.updateEmail(email)

  saveInvitation: ->
    if @invitation.isNewInvitation
      @list.addInvitation(@invitation)
    else
      @list.updateInvitation(@invitation)
    @invitation = new EditableInvitation()

  getInvitations: ->
    @list.list.invitations

  getInvitationsCount: ->
    @list.list.invitations.length

  getTotalGuests: ->
    @list.list.totalGuests()

  deleteInvitation: (id) ->
    @list.deleteInvitation(id)

  totalDeliveredInvitations: ->
    @list.list.totalDeliveredInvitations()

  confirmInvitationDelivery: (id) ->
    @list.confirmInvitationDelivery(id)

  unconfirmInvitationDelivery: (id) ->
    @list.unconfirmInvitationDelivery(id)

  totalConfirmedGuests: ->
    @list.list.totalConfirmedGuests()

  newAssistanceConfirmation: (id) ->
    invitation = @store.find(id)
    @confirmator = new AssistanceConfirmationControl(invitation, @)
    @confirmator.invitation

  confirmGuests: (count) ->
    if @confirmator
      @confirmator.confirmGuests(count)

  cancelAssistanceConfirmation: (invitation) ->
    @confirmator = undefined

  # old
  commitInvitationConfirmation: (invitation) ->
    @list.updateInvitation(invitation)
    @confirmator = undefined

class AssistanceConfirmationControl
  constructor: (invitation, @app) ->
    @invitation = new AssistanceConfirmableInvitation(invitation)

  confirmGuests: (count) ->
    if @invitation.validGuestsConfirmationCount(count)
      @invitation.setConfirmedGuests(count)
      @app.commitInvitationConfirmation(@invitation)
      true

  cancel: ->
    @app.cancelInvitationConfirmation(@invitation)

  class AssistanceConfirmableInvitation extends Invitation
    validGuestsConfirmationCount: (count) ->
      parseInt(count) >= 0

    setConfirmedGuests: (count) ->
      count = parseInt(count)
      @confirmedGuestsCount = count
      @isAssistanceConfirmed = true

class InvitationsListControl
  constructor: (@app, @store) ->
    @store.loadRecords(@)

  recordsLoaded: (records) ->
    @list = new InvitationsList(records)

  findInvitation: (id) ->
    @list.findInvitation(id)

  deleteInvitation: (id) ->
    @list.deleteInvitation(id)
    @store.deleteRecord(id)

  addInvitation: (title, guests) ->
    invitation = @list.addInvitation(title, guests)
    @store.saveRecord(invitation)

  editInvitation: (id) ->
    @app.editInvitation(@findInvitation(id))

  updateInvitation: (id, title, guests) ->
    invitation = @list.updateInvitation(id, title, guests)
    @store.updateRecord(invitation)

  confirmInvitationDelivery: (id) ->
    invitation = @list.confirmInvitationDelivery(id)
    @store.updateRecord(invitation)

  unconfirmInvitationDelivery: (id) ->
    invitation = @list.unconfirmInvitationDelivery(id)
    @store.updateRecord(invitation)

  startInvitationAssistanceConfirmation: (id) ->
    @app.startInvitationAssistanceConfirmation(@findInvitation(id))

class window.MemoryStore
  constructor: (@records = []) ->

  loadRecords: (listener) ->
    listener.recordsLoaded(@records)

  first: ->
    @records[0]

  find: (id) ->
    _.find @records, (record) -> record.id is id

  saveRecord: (record) ->
    record.id = @records.length + 1
    @records.push(record)

  updateRecord: (newRecord) ->
    @records = _.map @records, (current) ->
      if current.id is newRecord.id then newRecord else current

  deleteRecord: (id) ->
    @records = _.reject @records, (current) ->
      current.id is id

window.LocalStore =
  fetchRecords: ->
     JSON.parse(localStorage.invitations || "[]")

  updateRecords: (records) ->
    localStorage.invitations = JSON.stringify(records)

  loadRecords: (listener) ->
    listener.recordsLoaded(@fetchRecords())

  saveRecord: (record) ->
    records = @fetchRecords()
    records.push(record)
    @updateRecords records

  updateRecord: (newRecord) ->
    @updateRecords _.map @fetchRecords(), (current) ->
      if current.id is newRecord.id then newRecord else current

  deleteRecord: (id) ->
    @updateRecords _.reject @fetchRecords(), (current) ->
      current.id is id


window.RemoteStore =
  getListId: ->
    $("#app").data("listId")

  fetchRecords: ->
    url = "/lists/#{@getListId()}/invitations"
    $.getJSON(url).then (records) =>
      @records = records

  loadRecords: (listener) ->
    @fetchRecords().then =>
      listener.recordsLoaded(@records)

  saveRecord: (record) ->
    url = "/lists/#{@getListId()}/invitations"

    $.ajax
      method: "POST"
      url: url
      dataType: "json"
      data:
        invitation: JSON.stringify(record)

    @records.push(record)

  updateRecord: (newRecord) ->
    url = "/lists/#{@getListId()}/invitations"

    $.ajax
      method: "PATCH"
      url: url
      dataType: "json"
      data:
        invitation: JSON.stringify(newRecord)

    @records = _.map @records, (current) ->
      if current.id is newRecord.id then newRecord else current

  deleteRecord: (id) ->
    url = "/lists/#{@getListId()}/invitations/#{id}"

    $.ajax
      method: "DELETE"
      url: url
      dataType: "json"

    @records = _.reject @records, (current) ->
      current.id is id
