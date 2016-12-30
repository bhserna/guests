class window.ShowAllGuests
  constructor: (@store) ->
  all: -> @store.all()

class window.ShowAllInvitations
  constructor: (@store) ->
  invitations: -> @store.allInvitations()

class window.AddGuestsByInvitation
  constructor: (@store) ->
    @invitation = new Invitation
    @editInvitationTitle()

  isEditingInvitationTitle: ->
    @editingInvitationTitle

  addInvitationTitle: (title) ->
    @invitation.setTitle(title)
    @editingInvitationTitle = false

  editInvitationTitle: ->
    @editingInvitationTitle = true

  invitationTitle: ->
    @invitation.title

  addedGuests: ->
    @invitation.guests

  addGuest: (attrs) ->
    @invitation.addGuest(new Guest(attrs))

  editGuest: (id) ->
    @invitation.guestToEditionMode(id)

  updateGuest: (id, attrs) ->
    @invitation.updateGuest(id, attrs)

  commit: ->
    @store.addInvitation(@invitation)

  class window.Guest
    constructor: ({@name}) ->
      @isEditing = false

    setName: (name) ->
      @name = name

    setId: (id) ->
      @id = id

    toEditionMode: ->
      @isEditing = true

    turnOffEditionMode: ->
      @isEditing = false

  class window.Invitation
    constructor: ->
      @title = ""
      @guests = []

    setTitle: (title) ->
      @title = title

    guestToEditionMode: (id) ->
      guest = @findGuest(id)
      guest.toEditionMode()

    updateGuest: (id, attrs) ->
      guest = @findGuest(id)
      guest.setName(attrs.name)
      guest.turnOffEditionMode()

    findGuest: (id) ->
      (guest for guest in @guests when guest.id is id)[0]

    addGuest: (guest) ->
      guest.setId(@guests.length + 1)
      @guests.push(guest)

class window.MemoryStore
  constructor: (@records = []) ->
  allInvitations: -> @records
  addInvitation: (record) -> @records.push(record)

window.LocalStore =
  init: ->
     @records = JSON.parse(localStorage.invitations || "[]")

  allInvitations: ->
     @records

  addInvitation: (record) ->
     @records.push(record)
     localStorage.invitations = JSON.stringify(@records)
