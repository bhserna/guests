require "sinatra"
require 'sinatra/partial'

require_relative "lib/leads"
require_relative "lib/users"
require_relative "db/config"
require_relative "adapters"

set :partial_template_engine, :erb

helpers do
  def form_group(form, field, label, opts = {})
    input_type = opts.fetch(:input_type, "text")

    html = ""
    html += "<div class='form-group'>"
    html += "<label for='#{field}'>#{label}</label>"
    html += "<input type='#{input_type}' class='form-control' value='#{form.send(field)}' name='#{field}' id='#{field}'>"
    html += "</div>"
    html
  end

  def select_form_group(form, field, label, options)
    html = ""
    html += "<div class='form-group'>"
    html += "<label for='#{field}'>#{label}</label>"
    html += "<select class='form-control' name='#{field}' id='#{field}'>"
    html += options.map { |option| "<option #{form.send(field) == option[:value] ? "selected" : form.send(field)} value='#{option[:value]}'>#{option[:text]}</option>" }.join
    html += "</select>"
    html += "</div>"
    html
  end
end

get "/tests" do
  erb :tests
end

get "/" do
  erb :home
end

get "/lista-de-invitados" do
  erb :guests, layout: false
end

get "/registro" do
  @form = Users.register_form
  erb :"registration/new", layout: false
end

post '/registro' do
  response = Users.register_user(params, Users::Store, Users::Encryptor, Users::SessionStore)

  if response.success?
    redirect to("/home")
  else
    @form = response.form
    erb :"registration/new", layout: false
  end
end

get "/registro_exitoso" do
  erb :"registration/registered", layout: false
end

get "/registro_articulos" do
  @form = Leads.register_form
  erb :"lead_register/new_from_article", layout: false
end

post '/registro_articulos' do
  response = Leads.register_lead(params, Leads::Store)

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
