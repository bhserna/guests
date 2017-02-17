require "sinatra"
require 'sinatra/partial'

require_relative "lib/leads"
require_relative "lib/users"
require_relative "db/config"
require_relative "adapters"

require_relative "helpers/form_helpers"
require_relative "helpers/session_helpers"

set :partial_template_engine, :erb
enable :sessions
helpers FormHelpers, SessionHelpers

def users_config
  {store: Users::Store,
   encryptor: Users::Encryptor,
   session_store: Users::SessionStore.new(session)}
end

get "/tests" do
  erb :tests
end

get "/" do
  erb :wedding_planners_home, layout: :home_layout
end

get "/lista-de-invitados" do
  erb :guests
end

get "/registration" do
  redirect to("/home") if Users.user?(users_config)

  @form = Users.register_form
  erb :"users/registration"
end

post '/registration' do
  redirect to("/home") if Users.user?(users_config)
  registration = Users.register_user(params, users_config)

  if registration.success?
    redirect to("/home")
  else
    @form = registration.form
    erb :"users/registration"
  end
end

post "/sign_out" do
  Users.sign_out(users_config)
  redirect to("/")
end

get "/login" do
  redirect to("/home") if Users.user?(users_config)

  @form = Users.login_form
  erb :"users/login"
end

post "/login" do
  redirect to("/home") if Users.user?(users_config)
  login = Users.login(params, users_config)

  if login.success?
    redirect to("/home")
  else
    @form = Users.login_form
    @error = login.error
    erb :"users/login"
  end
end

get "/home" do
  redirect to("/") if Users.guest?(users_config)
  @user = users_config.fetch(:store).find(session[:user_id])
  erb :user_home
end

get "/articles/registration" do
  @form = Leads.register_form
  erb :"articles/registration"
end

post '/articles/registration' do
  response = Leads.register_lead(params, Leads::Store)

  if response.success?
    redirect to("/articles/registration_success")
  else
    @form = response.form
    erb :"articles/registration"
  end
end

get "/articles/registration_success" do
  erb :"articles/registration_success"
end

get "/articles/preguntas-para-reducir-su-lista-de-invitados" do
  @page_title = "Preguntas para reducir su lista de invitados"
  @meta_description = "Una pequeña guía de preguntas para ayudarlos a reducir su lista de invitados"
  erb :"articles/article-1", layout: :home_layout
end
