addInvitation = (app, title, guests, phone, email) ->
  app.addInvitation()
  app.editor.addTitle(title)
  app.editor.addGuest(name: guest) for guest in guests
  app.editor.updatePhone(phone)
  app.editor.updateEmail(email)
  app.editor.commit()

module.exports = addInvitation
