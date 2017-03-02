module SessionHelpers
  def user_signed_in?
    Users.user?(users_config)
  end
end
