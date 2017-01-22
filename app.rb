require "sinatra"

get "/" do
  erb :home
end

get "/lista-de-invitados" do
  erb :guests
end

get "/tests" do
  erb :tests
end
