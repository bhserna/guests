require "./guests.coffee"
Display = require "./display.coffee"

onAction = (event, selector, callback) ->
  $(document).on event, selector, (e) ->
    e.preventDefault()
    callback($el = $(this))

store = if $("#app").data("listId") then RemoteStore else (new MemoryStore)
app = new GuestsApp(store, new Display)

$ -> $("#invitationTitle").focus()

onAction "submit", "#addInvitationTitle", ($form) ->
  app.editor.addTitle($form.find("#invitationTitle").val())
  $("#name").focus()

onAction "submit", "#addGuest", ($form) ->
  app.editor.addGuest(name: $form.find("#name").val())
  $("#name").focus()

onAction "click", "#commitInvitation", ->
  app.editor.commit()
  $("#invitationTitle").focus()

onAction "click", "#editInvitationTitle", ->
  app.editor.turnOnTitleEdition()
  $("#invitationTitle").focus()

onAction "click", "#editInvitationGuest", ($el) ->
  id = $el.data("id")
  app.editor.turnOnGuestEdition(id)
  $("#guest_#{id}_name").focus()

onAction "click", "#deleteInvitationGuest", ($el) ->
  id = $el.data("id")
  app.editor.deleteGuest(id)
  $("#name").focus()

onAction "submit", "#updateGuest", ($form) ->
  id = $form.data("id")
  app.editor.updateGuest(id, name: $form.find("#guest_#{id}_name").val())
  $("#name").focus()

onAction "click", "#editInvitationPhone", ->
  app.editor.turnOnPhoneEdition()
  $("#phone").focus()

onAction "submit", "#updatePhone", ($form) ->
  app.editor.updatePhone($form.find("#phone").val())
  $("#name").focus()

onAction "click", "#editInvitationEmail", ->
  app.editor.turnOnEmailEdition()
  $("#email").focus()

onAction "submit", "#updateEmail", ($form) ->
  app.editor.updateEmail($form.find("#email").val())
  $("#name").focus()

onAction "click", "#editInvitation", ($el) ->
  id = $el.data("id")
  app.list.editInvitation(id)
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
