_ = require("underscore")
{renderable, p, a, span, div, h1, h3, h4, text, button, br, form, input, label, small, strong, ul, li, table, thead, tbody, tr, th, td, raw} = require("teacup")

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
  label ->
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
    style: "margin-right: 5px; margin-bottom: 5px;"
  }, opts)

textInput = defaultInput

phoneInput = renderable (id, opts = {}) ->
  defaultInput id, _.extend(opts, type: "phone")

emailInput = renderable (id, opts = {}) ->
  defaultInput id, _.extend(opts, type: "email")

editInvitationView = renderable (editor) ->
  h3 ->
    text (if editor.isNewInvitation then "Nueva invitación" else "Editar invitación")
  invitationField ->
    invitationLabel "Título de la invitación"
    if editor.isEditingTitle
      form "#addInvitationTitle", ->
        textInput "#invitationTitle", value: editor.title, placeholder: "Familia Perez"
        button ".btn.btn-default", type: "submit", "Agregar"
    else
      editButton "#editInvitationTitle"
      invitationValue editor.title

  unless editor.isEditingTitle
    invitationField ->
      invitationLabel "Invitados"
      ul ".list-unstyled", ->
        for guest in editor.guests
          li style: "border-bottom: 1px solid #eee; padding: 0.5em 0;", ->
            if guest.isEditing
              form "#updateGuest", "data-id": guest.id, style: "margin-bottom: 5px", ->
                textInput "#guest_#{guest.id}_name", value: guest.name, placeholder: "Juan Perez"
                button ".btn.btn-default", type: "submit", "Actualizar"
            else
              text guest.name
              editButton "#editInvitationGuest", "data-id": guest.id
              trashButton "#deleteInvitationGuest", "data-id": guest.id
        li style: "padding: 0.5em 0", ->
          form "#addGuest", ->
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
    div style: "margin-bottom: 1em", ->
      button "#commitInvitation.btn.btn-primary", "Guardar invitación"

invitationsView = renderable ({
  invitations,
  invitationsCount,
  totalGuests,
  totalDeliveredInvitations,
  totalConfirmedGuests
  }) ->
  div ".page-header", ->
    h3 "Invitaciones (#{invitationsCount})"
  div ".table-responsive", ->
    table ".table", ->
      thead ->
        tr ->
          th "Título"
          th "Invitados (#{totalGuests})"
          th "Contacto"
          th ".text-center", "¿Entregada? (#{totalDeliveredInvitations})"
          th ".text-center", "Confirmados (#{totalConfirmedGuests})"
          th()
      tbody ->
        for invitation in invitations
          tr ->
            td invitation.title
            td ->
              text  _.map(invitation.guests, (guest) -> guest.name).join ", "
            td ->
              if invitation.phone
                small ".text-muted", "Teléfono: "
                br()
                text invitation.phone
                br()
              if invitation.email
                small ".text-muted", "Correo: "
                br()
                text invitation.email
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
                span ".text-muted", " de "
                span ".text-muted", invitation.guests.length
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
            invitationField ->
              invitationLabel "Invitados"
              invitationValue confirmator.guests.length
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
    div ".col-md-3 clearfix", style: "background: #f9f9f9; border-radius: 5px; margin-top: 20px;", ->
      editInvitationView(data.editor)

    div ".col-md-9", ->
      invitationsView(data.list)

      if data.list.invitations.length < 2
        div ".alert.alert-info", style: "margin-top: 1em", ->
          h4 "Registra a tus invitados por invitación o familia"

          p ->
            strong "1. Escribe el nombre de la invitación."
            br()
            span "Ejemplo: 'Familia Perez Martinez' o 'Carlos Hernandez y Sra.'"
            br()
            span "Consejo: Usa 'Enter' en lugar de dar click en 'Agregar'"

          p ->
            strong "2. Agrega el nombre de las personas en esa invitación."
            br()
            span "Consejo: Usa 'Enter' en lugar de dar click en 'Agregar'"

          p ->
            strong "3. Da click en Guarda invitación"

      unless $("#app").data("listId")
        if data.list.invitations.length >= 2
          div ".alert.alert-warning", style: "margin-top: 1em", ->
            p "Los datos de esta lista no se guardan y se perderán al refrescar el navegador."
            p "Registrate para crear listas y guardar los datos en tu cuenta."


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

module.exports = Page
