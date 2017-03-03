class UsersRouter < BaseRouter
  get "/users/registration" do
    redirect to("/lists") if Users.user?(users_config)

    @form = Users.register_form
    erb :"users/registration"
  end

  post '/users/registration' do
    redirect to("/lists") if Users.user?(users_config)
    registration = Users.register_user(params, users_config)

    if registration.success?
      redirect to("/lists")
    else
      @form = registration.form
      erb :"users/registration"
    end
  end

  post "/users/sign_out" do
    Users.sign_out(users_config)
    redirect to("/")
  end

  get "/users/login" do
    redirect to("/lists") if Users.user?(users_config)

    @form = Users.login_form
    erb :"users/login"
  end

  post "/users/login" do
    redirect to("/lists") if Users.user?(users_config)
    login = Users.login(params, users_config)

    if login.success?
      redirect to("/lists")
    else
      @form = Users.login_form
      @error = login.error
      erb :"users/login"
    end
  end
end
