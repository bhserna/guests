require "active_record"
require "active_support/all"

namespace :db do
  desc "migrate your database"
  task :migrate do
    require "./lib/store/db_store/config"
    ActiveRecord::Migrator.migrate('lib/store/db_store/migrate')
  end
end
