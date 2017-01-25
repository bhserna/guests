require "sinatra"
require 'sinatra/partial'

require_relative "lib/leads"
require_relative "lib/register_wedding"
require_relative "lib/see_all_wedding_registrations"
require_relative "lib/store"

set :partial_template_engine, :erb
store = Store.for_env(settings.environment)::WeddingRegistrations.new

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
  @form = RegisterWedding.build_form
  erb :new_wedding_registration, layout: false
end

post '/registro' do
  registration = RegisterWedding.register(params, store)

  if registration.success?
    redirect to("/registro_exitoso")
  else
    @form = registration.form
    erb :new_wedding_registration, layout: false
  end
end

get "/registro_exitoso" do
  erb :wedding_registered, layout: false
end
