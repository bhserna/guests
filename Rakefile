require "./app"
require "active_record"
require "active_support/all"

namespace :db do
  desc "migrate your database"
  task :migrate do
    require "./db/config"
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    require "./db/config"
    ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
  end
end
