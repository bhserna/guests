require_relative "store/in_memory"
require_relative "store/postgres"

module Store
  CONFIG = {
    development: InMemoryStore,
    production: Postgres
  }

  def self.for_env(env)
    CONFIG.fetch(env)
  end
end
