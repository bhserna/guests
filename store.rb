require "active_record"

module Store
  module Leads
    class Lead < ActiveRecord::Base
    end

    def self.save(record)
      Lead.create(record)
    end

    def self.all
      Lead.all
    end
  end
end
