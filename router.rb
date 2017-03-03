require "sinatra"
require 'sinatra/partial'

require_relative "lib/leads"
require_relative "lib/users"
require_relative "lib/lists"
require_relative "lib/invitations"

require_relative "db/config"
require_relative "adapters"

require_relative "helpers/form_helpers"
require_relative "helpers/session_helpers"

require_relative "routers/base"
require_relative "routers/users"
require_relative "routers/articles"
require_relative "routers/lists"

class Router < BaseRouter
  get "/tests" do
    erb :tests, layout: false
  end

  get "/" do
    erb :wedding_planners_home, layout: :home_layout
  end

  get "/demo" do
    erb :guests
  end

  use UsersRouter
  use ArticlesRouter
  use ListsRouter
end
