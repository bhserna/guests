class Guest
  constructor: ({@id, @name})->

class Invitation
  constructor: ({@title, @guests})->

class window.GuestsApp
  constructor: (@store) ->
    @newInvitation = new NewInvitation(@store)
    @invitationsList = new InvitationsList(@store)

class InvitationsList
  constructor: (@store) ->
    @invitations = @store.allInvitations()

class NewInvitation
  constructor: (@store) ->
    @title = ""
    @guests = []
    @turnOnTitleEdition()

  addTitle: (title) ->
    @title = title
    @isEditingTitle = false

  turnOnTitleEdition: ->
    @isEditingTitle = true

  addGuest: (attrs) ->
    id = @guests.length + 1
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
    guests = (new Guest(guest) for guest in @guests)
    invitation = new Invitation(title: @title, guests: guests)
    @store.addInvitation(invitation)

  class EditableGuest extends Guest
    isEditing: false

    setName: (name) ->
      @name = name

    toEditionMode: ->
      @isEditing = true

    turnOffEditionMode: ->
      @isEditing = false

class window.EditInvitationWithGuests
  constructor: (@store) ->
    @invitation = null

  isActive: ->
    !!@invitation

  activateForInvitationWithId: (id) ->
    @invitation = @store.findInvitation(id)

class window.MemoryStore
  constructor: (@records = []) ->
  allInvitations: -> @records
  addInvitation: (record) -> @records.push(record)
  findInvitation: (id) -> _.findWhere(@record, id: id)

window.LocalStore =
  init: ->
     @records = JSON.parse(localStorage.invitations || "[]")

  allInvitations: ->
     @records

  addInvitation: (record) ->
     @records.push(record)
     localStorage.invitations = JSON.stringify(@records)
