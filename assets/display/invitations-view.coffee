_ = require("underscore")
{editButton, trashButton, undoButton} = require("./buttons.coffee")
{renderable, div, h3, small, table, thead, tr, th, tbody, td, smal, br, text, span, button} = require("teacup")

module.exports = renderable (list) ->
  div ".page-header", ->
    h3 "Invitaciones (#{list.invitations.length})"
  div ".table-responsive", ->
    table ".table", ->
      thead ->
        tr ->
          th "Título"
          th "Invitados (#{list.totalGuests()})"
          th "Contacto"
          th ".text-center", "¿Entregada? (#{list.totalDeliveredInvitations()})"
          th ".text-center", "Confirmados (#{list.totalConfirmedGuests()})"
          th()
      tbody ->
        for invitation in list.invitations
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
