require "sinatra"
require 'sinatra/partial'
require_relative "lib/leads"
require_relative "db/config"
require_relative "store"

set :partial_template_engine, :erb

store = Store::Leads

get "/" do
  erb :wedding_planners_home, layout: :home_layout
end

get "/lista-de-invitados" do
  erb :guests
end

get "/tests" do
  erb :tests, layout: false
end

get "/registro" do
  @form = Leads.register_form
  erb :"lead_register/new"
end

post '/registro' do
  response = Leads.register_lead(params, store)

  if response.success?
    redirect to("/registro_exitoso")
  else
    @form = response.form
    erb :"lead_register/new"
  end
end

get "/registro_exitoso" do
  erb :"lead_register/registered"
end

get "/registro_articulos" do
  @form = Leads.register_form
  erb :"lead_register/new_from_article"
end

post '/registro_articulos' do
  response = Leads.register_lead(params, store)

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
