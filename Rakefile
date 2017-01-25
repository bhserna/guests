require "active_record"
require "active_support/all"

namespace :db do
  desc "migrate your database"
  task :migrate do
    require "./lib/store/postgres/config"
    ActiveRecord::Migrator.migrate('lib/store/postgres/migrate')
  end
end
