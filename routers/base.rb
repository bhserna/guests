class BaseRouter < Sinatra::Application
  set :partial_template_engine, :erb
  enable :sessions
  helpers FormHelpers, SessionHelpers

  def session_store
    Users::SessionStore.new(session)
  end

  def users_config
    {store: Users::Store,
     encryptor: Users::Encryptor,
     session_store: session_store}
  end
end
