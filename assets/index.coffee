require "./guests.coffee"
View = require "./view.coffee"

onAction = (event, selector, callback) ->
  $(document).on event, selector, (e) ->
    e.preventDefault()
    callback($el = $(this))

store = if $("#app").data("listId") then RemoteStore else (new MemoryStore)
view = new View
app = new GuestsApp(store, view)


$ ->
  view.renderEditor(app.currentInvitation())
  $("#invitationTitle").focus()

onAction "submit", "#addInvitationTitle", ($form) ->
  view.renderEditor app.addInvitationTitle($form.find("#invitationTitle").val())
  $("#name").focus()

onAction "submit", "#addGuest", ($form) ->
  view.renderEditor app.addGuest(name: $form.find("#name").val())
  $("#name").focus()

onAction "click", "#commitInvitation", ->
  app.saveInvitation()
  view.renderEditor app.currentInvitation()
  $("#invitationTitle").focus()

onAction "click", "#editInvitationTitle", ->
  view.renderEditor app.turnOnTitleEdition()
  $("#invitationTitle").focus()

onAction "click", "#editInvitationGuest", ($el) ->
  id = $el.data("id")
  view.renderEditor app.turnOnGuestEdition(id)
  $("#guest_#{id}_name").focus()

onAction "click", "#deleteInvitationGuest", ($el) ->
  id = $el.data("id")
  view.renderEditor app.deleteGuest(id)
  $("#name").focus()

onAction "submit", "#updateGuest", ($form) ->
  id = $form.data("id")
  view.renderEditor app.updateGuest(id, name: $form.find("#guest_#{id}_name").val())
  $("#name").focus()

onAction "click", "#editInvitationPhone", ->
  view.renderEditor app.turnOnPhoneEdition()
  $("#phone").focus()

onAction "submit", "#updatePhone", ($form) ->
  view.renderEditor app.updatePhone($form.find("#phone").val())
  $("#name").focus()

onAction "click", "#editInvitationEmail", ->
  view.renderEditor app.turnOnEmailEdition()
  $("#email").focus()

onAction "submit", "#updateEmail", ($form) ->
  view.renderEditor app.updateEmail($form.find("#email").val())
  $("#name").focus()

onAction "click", "#editInvitation", ($el) ->
  id = $el.data("id")
  view.renderEditor app.editInvitation(id)
  $("#name").focus()

onAction "click", "#deleteInvitation", ($el) ->
  if confirm "¿Seguro que deseas eliminar la invitación?"
    id = $el.data("id")
    app.list.deleteInvitation(id)
    $("#name").focus()

onAction "click", "#confirmInvitationDelivery", ($el) ->
  id = $el.data("id")
  app.list.confirmInvitationDelivery(id)

onAction "click", "#unconfirmInvitationDelivery", ($el) ->
  id = $el.data("id")
  app.list.unconfirmInvitationDelivery(id)

onAction "click", "#startInvitationAssistanceConfirmation", ($el) ->
  id = $el.data("id")
  app.list.startInvitationAssistanceConfirmation(id)

onAction "submit", "#confirmInvitationGuests", ($form) ->
  app.confirmator.confirmGuests($form.find("#guests_count").val())

onAction "click", "#cancelInvitationConfirmation", ->
  app.confirmator.cancel()
