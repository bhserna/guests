{renderable, a, span, div, h3, h4, text, button, br, form, input, label, small, strong, ul, li, table, thead, tbody, tr, th, td, raw} = teacup

panel = renderable (title, content) ->
  div ".panel.panel-default", style: "margin-top: 10px", ->
    div ".panel-heading", ->
      h3 ".panel-title", title
    content()

panelBody = renderable (content) ->
  div ".panel-body", content

panelFooter = renderable (content) ->
  div ".panel-footer", content

invitationField = renderable (content) ->
  div style: "margin-bottom: 1em", content

invitationLabel = renderable (text) ->
  small ".text-muted", text

invitationValue = renderable (text) ->
  br()
  strong text

editButton = renderable (id, opts = {}) ->
  button "#{id}.btn.btn-link.btn-xs", opts, ->
    span ".glyphicon.glyphicon-pencil"

trashButton = renderable (id, opts = {}) ->
  button "#{id}.btn.btn-link.btn-xs", opts, ->
    span ".glyphicon.glyphicon-trash"

undoButton = renderable (id, opts = {}) ->
  button "#{id}.btn.btn-link.btn-xs", opts, ->
    span ".fa.fa-undo"

defaultInput = renderable (id, opts = {}) ->
  input "#{id}.form-control", _.extend({
    type: "text",
    style: "margin-right: 5px;"
  }, opts)

textInput = defaultInput

phoneInput = renderable (id, opts = {}) ->
  defaultInput id, _.extend(opts, type: "phone")

emailInput = renderable (id, opts = {}) ->
  defaultInput id, _.extend(opts, type: "email")

editInvitationView = renderable (editor) ->
  panel (if editor.isNewInvitation then "Nueva invitación" else "Editar invitación"), ->
    panelBody ->
      invitationField ->
        invitationLabel "Título de la invitación"
        if editor.isEditingTitle
          form "#addInvitationTitle.form-inline", ->
            textInput "#invitationTitle", value: editor.title, placeholder: "Familia Perez"
            button ".btn.btn-default", type: "submit", "Agregar"
        else
          editButton "#editInvitationTitle"
          invitationValue editor.title

      unless editor.isEditingTitle
        invitationField ->
          invitationLabel "Invitados"
          ul style: "padding-top: 5px; padding-left: 1.5em", ->
            for guest in editor.guests
              li style: "padding: 5px 0;", ->
                if guest.isEditing
                  form "#updateGuest.form-inline", "data-id": guest.id, style: "margin-bottom: 5px", ->
                    textInput "#guest_#{guest.id}_name", value: guest.name, placeholder: "Juan Perez"
                    button ".btn.btn-default", type: "submit", "Actualizar"
                else
                  text guest.name
                  editButton "#editInvitationGuest", "data-id": guest.id
                  trashButton "#deleteInvitationGuest", "data-id": guest.id
            li ->
              form "#addGuest.form-inline", ->
                textInput "#name", placeholder: "Juan Perez"
                button ".btn.btn-default", type: "submit", "Agregar"

        invitationField ->
          invitationLabel "Teléfono"
          if editor.isEditingPhone
            form "#updatePhone.form-inline", style: "margin-bottom: 5px", ->
              phoneInput "#phone", value: editor.phone
              button ".btn.btn-default", type: "submit", "Actualizar"
          else
            editButton "#editInvitationPhone"
            invitationValue editor.phone

        invitationField ->
          invitationLabel "Correo electrónico"
          if editor.isEditingEmail
            form "#updateEmail.form-inline", style: "margin-bottom: 5px", ->
              emailInput "#email", value: editor.email
              button ".btn.btn-default", type: "submit", "Actualizar"
          else
            editButton "#editInvitationEmail"
            invitationValue editor.email

    unless editor.isEditingTitle
      panelFooter ->
        button "#commitInvitation.btn.btn-primary", "Guardar invitación"

invitationsView = renderable (list) ->
  panel "Lista de invitaciones (#{list.invitations.length})", ->
    table ".table", ->
      thead ->
        tr ->
          th "Título"
          th "Invitados (#{list.totalGuests()})"
          th "Teléfono"
          th "Email"
          th ".text-center", "¿Entregada? (#{list.totalDeliveredInvitations()})"
          th ".text-center", "Confirmados (#{list.totalConfirmedGuests()})"
          th()
      tbody ->
        for invitation in list.invitations
          tr ->
            td invitation.title
            td ->
              text "(#{invitation.guests.length}) - "
              text  _.map(invitation.guests, (guest) -> guest.name).join ", "
            td invitation.phone
            td invitation.email
            td ".text-center", ->
              if invitation.isDelivered
                span "Sí "
                undoButton "#unconfirmInvitationDelivery", "data-id": invitation.id
              else
                button "#confirmInvitationDelivery.btn.btn-default.btn-sm", "data-id": invitation.id, ->
                  text "Confirmar entrega"
            td ".text-center", ->
              if invitation.isAssistanceConfirmed
                text invitation.confirmedGuestsCount
                editButton "#startInvitationAssistanceConfirmation", "data-id": invitation.id
              else
                button "#startInvitationAssistanceConfirmation.btn.btn-default.btn-sm", "data-id": invitation.id, ->
                  text "Confirmar asistencia"
            td ".text-right", ->
              editButton "#editInvitation", "data-id": invitation.id
              trashButton "#deleteInvitation", "data-id": invitation.id

confirmAssistanceView = renderable (confirmator) ->
  div ".modal.fade", tabindex: "-1", role: "dialog", ->
    div ".modal-dialog", ->
      div ".modal-content", ->
        div ".modal-header", ->
          h4 ".modal-title", "Confirmación de asistencia"
        form "#confirmInvitationGuests.form-inline", style: "margin-bottom: 5px", ->
          div ".modal-body", ->
            invitationField ->
              invitationLabel "Invitación"
              invitationValue confirmator.title
            if confirmator.phone
              invitationField ->
                invitationLabel "Teléfono"
                invitationValue confirmator.phone
            invitationField ->
              invitationLabel "Número de asistentes"
              br()
              textInput "#guests_count", value: confirmator.confirmedGuestsCount
          div ".modal-footer", ->
            button "#cancelInvitationConfirmation.btn.btn-default", type: "button", "Cancelar"
            button ".btn.btn-primary", type: "submit", "Guardar"

view = renderable (data) ->
  div ".row", ->
    div ".col-md-4", ->
      editInvitationView(data.editor)
    div ".col-md-8", ->
      invitationsView(data.list)

class Page
  constructor: ->
    @editor = null
    @list = null

  renderEditor: (data) ->
    @editor = data
    @render()

  renderList: (data) ->
    @list = data
    @render()

  renderConfirmator: (data) ->
    @$confirmatorHtml = $(confirmAssistanceView(data))
    $("body").append(@$confirmatorHtml)
    @$confirmatorHtml.on 'shown.bs.modal', ->
       $("#guests_count").focus()
    @$confirmatorHtml.modal(backdrop: false, keybord: false)

  removeConfirmator: ->
    @$confirmatorHtml.modal("hide")
    @$confirmatorHtml.on 'hidden.bs.modal', =>
      @$confirmatorHtml.remove()

  render: ->
    if @editor and @list
      $("#app").html(view(@))

onAction = (event, selector, callback) ->
  $(document).on event, selector, (e) ->
    e.preventDefault()
    callback($el = $(this))

app = new GuestsApp(LocalStore, new Page)

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
