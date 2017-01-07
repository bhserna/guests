{renderable, span, div, h3, text, button, br, form, input, label, small, strong, ul, li, table, thead, tbody, tr, th, td, raw} = teacup

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
  panel (if editor.isNewInvitation then "Nueva invitación" else "Editar invitación"), ->
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
        button "#editInvitationTitle.btn.btn-link.btn-xs", ->
          span ".glyphicon.glyphicon-pencil"
        br()
        br()
        small ".text-muted", "Invitados"
        br()
        ul style: "padding-left: 1.5em", ->
          for guest in editor.guests
            li style: "padding: 5px 0;", ->
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
                button "#editInvitationGuest.btn.btn-link.btn-xs", "data-id": guest.id, ->
                  span ".glyphicon.glyphicon-pencil"
                button "#deleteInvitationGuest.btn.btn-link.btn-xs", "data-id": guest.id, ->
                  span ".glyphicon.glyphicon-trash"
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
  panel "Lista de invitaciones (#{list.invitations.length})", ->
    table ".table", ->
      thead ->
        tr ->
          th "Título"
          th "Invitados"
          th "Total de invitados (#{list.totalGuests()})"
          th()
      tbody ->
        for invitation in list.invitations
          tr ->
            td invitation.title
            td _.map(invitation.guests, (guest) -> guest.name).join ", "
            td invitation.guests.length
            td ".text-right", ->
              button "#editInvitation.btn.btn-link.btn-xs", "data-id": invitation.id, ->
                span ".glyphicon.glyphicon-pencil"
              button "#deleteInvitation.btn.btn-link.btn-xs", "data-id": invitation.id, ->
                span ".glyphicon.glyphicon-trash"

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

  render: ->
    if @editor and @list
      $("#app").html(view(@))

onAction = (event, selector, callback) ->
  $(document).on event, selector, (e) ->
    e.preventDefault()
    callback($el = $(this))

page = new Page
app = new GuestsApp(LocalStore, page)

$ -> $("#invitationTitle").focus()

onAction "submit", "#addInvitationTitle", ($form) ->
  console.log app
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

onAction "click", "#editInvitation", ($el) ->
  id = $el.data("id")
  app.list.editInvitation(id)
  $("#name").focus()

onAction "click", "#deleteInvitation", ($el) ->
  if confirm "¿Seguro que deseas eliminar la invitación?"
    id = $el.data("id")
    app.list.deleteInvitation(id)
    $("#name").focus()
