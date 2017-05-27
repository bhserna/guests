require "./guests.coffee"
View = require "./view.coffee"

onAction = (event, selector, callback) ->
  $(document).on event, selector, (e) ->
    e.preventDefault()
    callback($el = $(this))

store = if $("#app").data("listId") then RemoteStore else (new MemoryStore)
view = new View
app = new GuestsApp(store, view)

renderList = ->
  list =
    invitations: app.getInvitations()
    invitationsCount: app.getInvitationsCount()
    totalGuests: app.getTotalGuests()
    totalDeliveredInvitations: app.totalDeliveredInvitations()
    totalConfirmedGuests: app.totalConfirmedGuests()
  view.renderList(list)

renderEditor = ->
  view.renderEditor app.currentInvitation()

renderAssistanceConfirmation = (confirmation) ->
  view.renderConfirmator(confirmation)

closeAssistanceConfirmation = ->
  view.removeConfirmator()

$ ->
  renderEditor()
  renderList()
  $("#invitationTitle").focus()

onAction "submit", "#addInvitationTitle", ($form) ->
  app.addInvitationTitle($form.find("#invitationTitle").val())
  renderEditor()
  $("#name").focus()

onAction "submit", "#addGuest", ($form) ->
  app.addGuest(name: $form.find("#name").val())
  renderEditor()
  $("#name").focus()

onAction "click", "#commitInvitation", ->
  app.saveInvitation()
  renderEditor()
  renderList()
  $("#invitationTitle").focus()

onAction "click", "#editInvitationTitle", ->
  app.turnOnTitleEdition()
  renderEditor()
  $("#invitationTitle").focus()

onAction "click", "#editInvitationGuest", ($el) ->
  id = $el.data("id")
  app.turnOnGuestEdition(id)
  renderEditor()
  $("#guest_#{id}_name").focus()

onAction "click", "#deleteInvitationGuest", ($el) ->
  id = $el.data("id")
  app.deleteGuest(id)
  renderEditor()
  $("#name").focus()

onAction "submit", "#updateGuest", ($form) ->
  id = $form.data("id")
  app.updateGuest(id, name: $form.find("#guest_#{id}_name").val())
  renderEditor()
  $("#name").focus()

onAction "click", "#editInvitationPhone", ->
  app.turnOnPhoneEdition()
  renderEditor()
  $("#phone").focus()

onAction "submit", "#updatePhone", ($form) ->
  app.updatePhone($form.find("#phone").val())
  renderEditor()
  $("#name").focus()

onAction "click", "#editInvitationEmail", ->
  app.turnOnEmailEdition()
  renderEditor()
  $("#email").focus()

onAction "submit", "#updateEmail", ($form) ->
  app.updateEmail($form.find("#email").val())
  renderEditor()
  $("#name").focus()

onAction "click", "#editInvitation", ($el) ->
  id = $el.data("id")
  app.editInvitation(id)
  renderEditor()
  $("#name").focus()

onAction "click", "#deleteInvitation", ($el) ->
  if confirm "¿Seguro que deseas eliminar la invitación?"
    id = $el.data("id")
    app.deleteInvitation(id)
    renderList()
    $("#name").focus()

onAction "click", "#confirmInvitationDelivery", ($el) ->
  id = $el.data("id")
  app.confirmInvitationDelivery(id)
  renderList()

onAction "click", "#unconfirmInvitationDelivery", ($el) ->
  id = $el.data("id")
  app.unconfirmInvitationDelivery(id)
  renderList()

onAction "click", "#startInvitationAssistanceConfirmation", ($el) ->
  id = $el.data("id")
  confirmation = app.newAssistanceConfirmation(id)
  renderAssistanceConfirmation(confirmation)

onAction "submit", "#confirmInvitationGuests", ($form) ->
  if app.confirmGuests($form.find("#guests_count").val())
    closeAssistanceConfirmation()
    renderList()

onAction "click", "#cancelInvitationConfirmation", ->
  app.cancelAssistanceConfirmation()
  closeAssistanceConfirmation()
