addInvitation = (app, title, guests, phone, email) ->
  app.addInvitationTitle(title)
  app.addGuest(name: guest) for guest in guests
  app.updatePhone(phone)
  app.updateEmail(email)
  app.saveInvitation()

module.exports = addInvitation
