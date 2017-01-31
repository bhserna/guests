require "sinatra"
require 'sinatra/partial'

require_relative "lib/leads"
require_relative "lib/store/db_store/config"
require_relative "lib/store"

set :partial_template_engine, :erb

store = Store::DbStore.new

get "/" do
  erb :home
end

get "/lista-de-invitados" do
  erb :guests, layout: false
end

get "/tests" do
  erb :tests
end

get "/registro" do
  @form = Leads.register_form
  erb :"lead_register/new", layout: false
end

post '/registro' do
  response = Leads.register_lead(params, store)

  if response.success?
    redirect to("/registro_exitoso")
  else
    @form = response.form
    erb :"lead_register/new", layout: false
  end
end

get "/registro_exitoso" do
  erb :"lead_register/registered", layout: false
end

get "/registro_articulos" do
  @form = Leads.register_form
  erb :"lead_register/new_from_article", layout: false
end

post '/registro_articulos' do
  response = Leads.register_lead(params, store)

  if response.success?
    redirect to("/registro_articulos_exitoso")
  else
    @form = response.form
    erb :"lead_register/new_from_article", layout: false
  end
end

get "/registro_articulos_exitoso" do
  erb :"lead_register/registered_from_article", layout: false
end

get "/articles/preguntas-para-reducir-tu-lista-de-invitados" do
  erb :"articles/article-1"
end
