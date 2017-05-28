{invitationValue, invitationField, invitationLabel} = require("./invitation-elements.coffee")
{textInput, phoneInput, emailInput} = require("./inputs.coffee")
{editButton, trashButton} = require("./buttons.coffee")
{renderable, h3, text, form, button, ul, li, form, div} = require("teacup")

module.exports = renderable (editor) ->
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

