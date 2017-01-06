class Guest
  constructor: ({@id, @name})->

class Invitation
  constructor: ({@id, @title, @guests})->

class EditableInvitation
  constructor: (opts = {}) ->
    @id = opts.id
    @title = opts.title or ""
    @guests = (new EditableGuest(guest) for guest in (opts.guests or []))
    @turnOnTitleEdition()

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

class EditableGuest extends Guest
  isEditing: false

  setName: (name) ->
    @name = name

  toEditionMode: ->
    @isEditing = true

  turnOffEditionMode: ->
    @isEditing = false

class window.GuestsApp
  constructor: (@store, @display) ->
    @list = new InvitationsList(@store, @display)
    @addInvitation()

  addInvitation: ->
    invitation = new EditableInvitation
    @editor = new NewInvitationControl(invitation, @, @display)

  commitAddition: (invitation) ->
    @list.addInvitation(invitation.title, invitation.guests)
    @addInvitation()

  editInvitationWithId: (id) ->
    invitation = new EditableInvitation(@list.findInvitation(id))
    @editor = new EditInvitationControl(invitation, @, @display)

  commitEdition: (invitation)->
    @list.updateInvitation(invitation.id, invitation.title, invitation.guests)
    @addInvitation()

class InvitationsList
  constructor: (@store, @display) ->
    @invitations = @store.fetchRecords()
    @display.renderList(@)

  findInvitation: (id) ->
    _.findWhere(@invitations, id: id)

  addInvitation: (title, guests) ->
    id = @invitations.length + 1
    invitation = @_buildInvitation(id, title, guests)
    @invitations.push(invitation)
    @store.updateRecords(@invitations)
    @display.renderList(@)

  updateInvitation: (id, title, guests) ->
    invitation = @_buildInvitation(id, title, guests)
    @invitations = _.reject(@invitations, (invitation) -> invitation.id is id)
    @invitations.push(invitation)
    @invitations = _.sortBy(@invitations, "id")
    @store.updateRecords(@invitations)
    @display.renderList(@)

  _buildInvitation: (id, title, guests) ->
    guests = (new Guest(guest) for guest in guests)
    invitation = new Invitation(id: id, title: title, guests: guests)

class EditInvitationControl
  isAddingInvitation: false
  isEditingInvitation: true

  constructor: (@invitation, @app, @display) ->
    @render()

  render: ->
    state = _.extend(
      _.pick(@invitation, "title", "isEditingTitle", "guests"),
      _.pick(@, "isAddingInvitation", "isEditingInvitation"))
    @display.renderEditor(state)

  addTitle: (title) ->
    @invitation.addTitle(title)
    @render()

  turnOnTitleEdition: ->
    @invitation.turnOnTitleEdition()
    @render()

  addGuest: (attrs) ->
    @invitation.addGuest(attrs)
    @render()

  turnOnGuestEdition: (id) ->
    @invitation.turnOnGuestEdition(id)
    @render()

  updateGuest: (id, attrs) ->
    @invitation.updateGuest(id, attrs)
    @render()

  commit: ->
    @app.commitEdition(@invitation)

class NewInvitationControl extends EditInvitationControl
  isAddingInvitation: true
  isEditingInvitation: false
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
