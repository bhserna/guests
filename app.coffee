class Guest
  constructor: ({@id, @name})->

class Invitation
  constructor: ({@id, @title, @guests})->

class window.GuestsApp
  constructor: (@store) ->
    @invitationsList = new InvitationsList(@store)
    @invitationEditor = new InvitationEditor(@invitationsList)
    @addInvitation()

  addInvitation: ->
    @invitationEditor.addInvitation()

  editInvitationWithId: (id) ->
    @invitationEditor.editInvitationWithId(id)

class InvitationsList
  constructor: (@store) ->
    @invitations = @store.fetchRecords()

  findInvitation: (id) ->
    _.findWhere(@invitations, id: id)

  addInvitation: (title, guests) ->
    id = @invitations.length + 1
    invitation = @_buildInvitation(id, title, guests)
    @invitations.push(invitation)
    @store.updateRecords(@invitations)

  updateInvitation: (id, title, guests) ->
    invitation = @_buildInvitation(id, title, guests)
    @invitations = _.reject(@invitations, (invitation) -> invitation.id is id)
    @invitations.push(invitation)
    @invitations = _.sortBy(@invitations, "id")
    @store.updateRecords(@invitations)

  _buildInvitation: (id, title, guests) ->
    guests = (new Guest(guest) for guest in guests)
    invitation = new Invitation(id: id, title: title, guests: guests)

class InvitationEditor
  constructor: (@list) ->
    @init()

  init: (opts = {})->
    @title = opts.title or ""
    @guests = (new EditableGuest(guest) for guest in (opts.guests or []))
    @turnOnTitleEdition()

  addInvitation: ->
    @isAddingInvitation = true
    @isEditingInvitation = false

  editInvitationWithId: (id) ->
    @id = id
    @isAddingInvitation = false
    @isEditingInvitation = true
    @init(@list.findInvitation(id))
    @isEditingTitle = false

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

  findGuest: (id) ->
    (guest for guest in @guests when guest.id is id)[0]

  commit: ->
    if @isAddingInvitation
      @list.addInvitation(@title, @guests)
    else
      @list.updateInvitation(@id, @title, @guests)
      @addInvitation()
    @init()

  class EditableGuest extends Guest
    isEditing: false

    setName: (name) ->
      @name = name

    toEditionMode: ->
      @isEditing = true

    turnOffEditionMode: ->
      @isEditing = false

class EditInvitation
  constructor: (@store) ->
    @isActive = false

  editInvitationWithId: (id) ->
    @isActive = true
    invitation = @store.findInvitation(id)
    @title = invitation.title
    @guests = invitation.guests

class window.MemoryStore
  constructor: (@records = []) ->
  fetchRecords: -> @records
  updateRecords: (records) -> @records = records

window.LocalStore =
  fetchRecords: ->
     JSON.parse(localStorage.invitations || "[]")

  updateRecords: (records) ->
    localStorage.invitations = JSON.stringify(records)
