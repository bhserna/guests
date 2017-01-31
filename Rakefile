require "./app"
require "active_record"
require "active_support/all"

namespace :db do
  desc "migrate your database"
  task :migrate do
    require "./db/config"
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
