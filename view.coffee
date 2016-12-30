renderCollection = (template, collection, opts = {}) ->
  (template(item) for item in collection).join opts.joinWith or ""

renderUnless = (condition, html) ->
  if condition then "" else html

renderIf = (condition, html) ->
  if condition then html else ""

newInvitationView = (adder) -> """
<div class="panel panel-default" style="margin-top: 10px">
  <div class="panel-heading">
    <h3 class="panel-title">Nueva invitación</h3>
  </div>
  <div class="panel-body">
  #{renderIf adder.isEditingInvitationTitle(), invitationTitleFormView(adder)}
  #{renderUnless adder.isEditingInvitationTitle(), invitationTitleView(adder)}
  #{renderUnless adder.isEditingInvitationTitle(), invitationGuestsView(adder)}
  </div>
  #{renderIf adder.addedGuests().length, invitationCommitView()}
</div>
"""

invitationCommitView = -> """
<div class="panel-footer">
  <button id="commitInvitation" class="btn btn-primary">
  Guardar invitación
  </button>
</div>
"""

invitationGuestsView = (adder) -> """
<br/>
<br/>
<small class="text-muted">Invitados</small>
<br/>
<ul style="padding-left: 1.5em">
#{renderCollection invitationGuestView, adder.addedGuests()}
<li>
#{guestFormView()}
</li>
</ul>
"""

invitationGuestView = (guest) ->
  form = -> """
  <form id="updateGuest" data-id="#{guest.id}" class="form-inline" style="margin-bottom: 5px">
    <div class="form-group">
      <input type="text" style="max-width: 300px" class="form-control"
       id="guest_#{guest.id}_name"
       value="#{guest.name}"
       placeholder="Juan Perez">
    </div>
    <button type="submit" class="btn btn-default">Actualizar</button>
  </form>
  """

  display = -> """
  #{guest.name}
  <button class="btn btn-link btn-sm"
   id="editInvitationGuest"
   data-id="#{guest.id}">Editar</button>
  """

  """
  <li>
  #{renderIf guest.isEditing, form()}
  #{renderUnless guest.isEditing, display()}
  </li>
  """

invitationTitleView = (adder) -> """
<small class="text-muted">Título de la invitación</small>
<br/><strong>#{adder.invitationTitle()}</strong>
<button class="btn btn-link btn-sm" id="editInvitationTitle">Editar</button>
"""

invitationTitleFormView = (adder) -> """
<form id="addInvitationTitle">
  <div class="form-group" style="margin-right: 10px;">
    <label for="invitationTitle">Título de la invitación</label>
    <input type="text" style="max-width: 300px" class="form-control"
     id="invitationTitle"
     value="#{adder.invitationTitle()}"
     placeholder="Familia Perez">
  </div>
  <button type="submit" class="btn btn-default">Agregar</button>
</form>
"""

guestFormView = -> """
<form id="addGuest" class="form-inline">
  <div class="form-group">
    <input type="text" style="max-width: 300px" class="form-control"
     id="name" placeholder="Juan Perez">
  </div>
  <button type="submit" class="btn btn-default">Agregar</button>
</form>
"""

invitationsView = (list) -> """
<div class="panel panel-default" style="margin-top: 10px">
  <div class="panel-heading">
    <h3 class="panel-title">Lista de invitaciones</h3>
  </div>
  <table class="table">
    <thead>
      <tr>
        <th>Títlulo</th>
        <th>Invitados</th>
      </tr>
    </thead>
    <tbody>
      #{renderCollection invitationItemView, list.invitations()}
    </tbody>
  </table>
</div>
"""

invitationItemView = (invitation) -> """
<tr>
  <td>#{invitation.title}</td>
  <td>#{renderCollection ((guest) -> guest.name), invitation.guests, joinWith: ", "}</td>
</tr>
"""

view = (adder, list) -> """
<div class="row">
  <div class="col-md-4">
  #{newInvitationView(adder)}
  </div>
  <div class="col-md-8">
  #{invitationsView(list)}
  </div>
</div>
"""

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
