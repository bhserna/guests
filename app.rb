require "sinatra"
require 'sinatra/partial'

require_relative "lib/leads"
require_relative "lib/users"
require_relative "db/config"
require_relative "adapters"

require_relative "helpers/form_helpers"

set :partial_template_engine, :erb
enable :sessions
helpers FormHelpers

get "/tests" do
  erb :tests
end

get "/" do
  erb :wedding_planners_home, layout: :home_layout
end

get "/lista-de-invitados" do
  erb :guests
end

get "/registro" do
  @form = Users.register_form
  erb :"registration/new"
end

post '/registro' do
  response = Users.register_user(params, Users::Store, Users::Encryptor, Users::SessionStore.new(session))

  if response.success?
    redirect to("/home")
  else
    @form = response.form
    erb :"registration/new"
  end
end

get "/home" do
  @user = Users::Store.find(session[:user_id])
  erb :user_home, layout: false
end

get "/registro_exitoso" do
  erb :"registration/registered"
end

get "/registro_articulos" do
  @form = Leads.register_form
  erb :"lead_register/new_from_article"
end

post '/registro_articulos' do
  response = Leads.register_lead(params, Leads::Store)

  if response.success?
    redirect to("/registro_articulos_exitoso")
  else
    @form = response.form
    erb :"lead_register/new_from_article"
  end
end

get "/registro_articulos_exitoso" do
  erb :"lead_register/registered_from_article"
end

get "/articles/preguntas-para-reducir-su-lista-de-invitados" do
  @page_title = "Preguntas para reducir su lista de invitados"
  @meta_description = "Una pequeña guía de preguntas para ayudarlos a reducir su lista de invitados"
  erb :"articles/article-1", layout: :home_layout
end
