{renderable, div, h3, text, button, br, form, input, label, small, strong, ul, li, table, thead, tbody, tr, th, td, raw} = teacup

panel = renderable (title, content) ->
  div ".panel.panel-default", style: "margin-top: 10px", ->
    div ".panel-heading", ->
      h3 ".panel-title", title
    content()

panelBody = renderable (content) ->
  div ".panel-body", content

panelFooter = renderable (content) ->
  div ".panel-footer", content

editInvitationView = renderable (editor) ->
  panel (if editor.isAddingInvitation then "Nueva invitación" else "Editar invitación"), ->
    panelBody ->
      if editor.isEditingTitle
        form "#addInvitationTitle", ->
          div ".form-group", style: "margin-right: 10px;", ->
            label for: "invitationTitle", "Título de la invitación"
            input "#invitationTitle.form-control",
              type: "text",
              style: "max-width: 300px",
              value: editor.title,
              placeholder: "Familia Perez"
          button ".btn.btn-default", ype: "submit", "Agregar"
      else
        small ".text-muted", "Título de la invitación"
        br()
        strong editor.title
        button "#editInvitationTitle.btn.btn-link.btn-sm", "Editar"
        br()
        br()
        small ".text-muted", "Invitados"
        br()
        ul style: "padding-left: 1.5em", ->
          for guest in editor.guests
            li ->
              if guest.isEditing
                form "#updateGuest.form-inline", "data-id": guest.id, style: "margin-bottom: 5px", ->
                  div ".form-group", ->
                    input "#guest_#{guest.id}_name.form-control",
                      type: "text",
                      style: "max-width: 300px; margin-right: 5px;",
                      value: guest.name,
                      placeholder: "Juan Perez"
                  button ".btn.btn-default", type: "submit", "Actualizar"
              else
                text guest.name
                button "#editInvitationGuest.btn.btn-link.btn-sm", "data-id": guest.id, ->
                  text "Editar"
          li ->
            form "#addGuest.form-inline", ->
              div ".form-group", ->
                input "#name.form-control",
                  type: "text",
                  style: "max-width: 300px; margin-right: 5px;",
                  placeholder: "Juan Perez"
              button ".btn.btn-default", type: "submit", "Agregar"
    if editor.guests.length and not editor.isEditingTitle
      panelFooter ->
        button "#commitInvitation.btn.btn-primary", "Guardar invitación"

invitationsView = renderable (list) ->
  panel "Lista de invitaciones", ->
    table ".table", ->
      thead ->
        tr ->
          th "Título"
          th "Invitados"
          th()
      tbody ->
        for invitation in list.invitations
          tr ->
            td invitation.title
            td _.map(invitation.guests, (guest) -> guest.name).join ", "
            td ->
              button "#editInvitation.btn.btn-link.btn-xs", "data-id": invitation.id, ->
                text "Editar"

view = renderable (editor, list) ->
  div ".row", ->
    div ".col-md-4", ->
      editInvitationView(editor)
    div ".col-md-8", ->
      invitationsView(list)

$ ->
  window.app = new GuestsApp(LocalStore)
  list = app.invitationsList
  editor = app.invitationEditor
  render = (app) -> $("#app").html(view(editor, list))
  render()

  $("#invitationTitle").focus()

  $(document).on "submit", "#addInvitationTitle", (e) ->
    e.preventDefault()
    $form = $(this)
    editor.addTitle($form.find("#invitationTitle").val())
    render()
    $("#name").focus()

  $(document).on "submit", "#addGuest", (e) ->
    e.preventDefault()
    $form = $(this)
    editor.addGuest(name: $form.find("#name").val())
    render()
    $("#name").focus()

  $(document).on "click", "#commitInvitation", (e) ->
    e.preventDefault()
    editor.commit()
    render()
    $("#invitationTitle").focus()

  $(document).on "click", "#editInvitationTitle", (e) ->
    e.preventDefault()
    editor.turnOnTitleEdition()
    render()
    $("#invitationTitle").focus()

  $(document).on "click", "#editInvitationGuest", (e) ->
    e.preventDefault()
    id = $(this).data("id")
    editor.turnOnGuestEdition(id)
    render()
    $("#guest_#{id}_name").focus()

  $(document).on "submit", "#updateGuest", (e) ->
    e.preventDefault()
    $form = $(this)
    id = $form.data("id")
    editor.updateGuest(id, name: $form.find("#guest_#{id}_name").val())
    render()
    $("#name").focus()

  $(document).on "click", "#editInvitation", (e) ->
    e.preventDefault()
    id = $(this).data("id")
    app.editInvitationWithId(id)
    render()
    $("#name").focus()
