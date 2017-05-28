{invitationValue, invitationField, invitationLabel} = require("./invitation-elements.coffee")
{textInput} = require("./inputs.coffee")
{renderable, div, br, h4, form, button} = require("teacup")

module.exports = renderable (confirmator) ->
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
