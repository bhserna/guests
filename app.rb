require "sinatra"
require_relative "lib/leads"

require_relative "lib/store/db_store/config"
require_relative "lib/store"
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
  erb :new_lead, layout: false
end

post '/registro' do
  response = Leads.register_lead(params, store)
  puts params.inspect
  if response.success?
    redirect to("/registro_exitoso")
  else
    @form = response.form
    erb :new_lead, layout: false
  end
end

get "/registro_exitoso" do
  erb :registered_lead, layout: false
end
