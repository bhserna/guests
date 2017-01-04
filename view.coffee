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

newInvitationView = renderable (adder) ->
  panel "Nueva invitación", ->
    panelBody ->
      if adder.isEditingInvitationTitle()
        form "#addInvitationTitle", ->
          div ".form-group", style: "margin-right: 10px;", ->
            label for: "invitationTitle", "Título de la invitación"
            input "#invitationTitle.form-control",
              type: "text",
              style: "max-width: 300px",
              value: adder.invitationTitle(),
              placeholder: "Familia Perez"
          button ".btn.btn-default", ype: "submit", "Agregar"
      else
        small ".text-muted", "Título de la invitación"
        br()
        strong adder.invitationTitle()
        button "#editInvitationTitle.btn.btn-link.btn-sm", "Editar"
        br()
        br()
        small ".text-muted", "Invitados"
        br()
        ul style: "padding-left: 1.5em", ->
          for guest in adder.addedGuests()
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
    if adder.addedGuests().length and not adder.isEditingInvitationTitle()
      panelFooter ->
        button "#commitInvitation.btn.btn-primary", "Guardar invitación"

invitationsView = renderable (list) ->
  panel "Lista de invitaciones", ->
    table ".table", ->
      thead ->
        tr ->
          th "Título"
          th "Invitados"
      tbody ->
        for invitation in list.invitations()
          tr ->
            td invitation.title
            td _.map(invitation.guests, (guest) -> guest.name).join ", "

view = renderable (adder, list) ->
  div ".row", ->
    div ".col-md-4", ->
      newInvitationView(adder)
    div ".col-md-8", ->
      invitationsView(list)

render = (adder, list) ->
  $("#app").html(view(adder, list))

$ ->
  LocalStore.init()
  store = LocalStore
  adder = new AddGuestsByInvitation(store)
  list = new ShowAllInvitations(store)
  render(adder, list)
  $("#invitationTitle").focus()

  $(document).on "submit", "#addInvitationTitle", (e) ->
    e.preventDefault()
    $form = $(this)
    adder.addInvitationTitle($form.find("#invitationTitle").val())
    render(adder, list)
    $("#name").focus()

  $(document).on "submit", "#addGuest", (e) ->
    e.preventDefault()
    $form = $(this)
    adder.addGuest(name: $form.find("#name").val())
    render(adder, list)
    $("#name").focus()

  $(document).on "click", "#commitInvitation", (e) ->
    e.preventDefault()
    adder.commit()
    adder = new AddGuestsByInvitation(store)
    render(adder, list)
    $("#invitationTitle").focus()

  $(document).on "click", "#editInvitationTitle", (e) ->
    e.preventDefault()
    adder.editInvitationTitle()
    render(adder, list)
    $("#invitationTitle").focus()

  $(document).on "click", "#editInvitationGuest", (e) ->
    e.preventDefault()
    id = $(this).data("id")
    adder.editGuest(id)
    render(adder, list)
    $("#guest_#{id}_name").focus()

  $(document).on "submit", "#updateGuest", (e) ->
    e.preventDefault()
    $form = $(this)
    id = $form.data("id")
    adder.updateGuest(id, name: $form.find("#guest_#{id}_name").val())
    render(adder, list)
    $("#name").focus()
