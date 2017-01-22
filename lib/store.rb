require "active_record"

module Store
  class InMemoryStore
    def initialize
      @records = []
    end

    def save(record)
      @records << record
    end

    def all
      @records
    end
  end

  class DbStore
    class Lead < ActiveRecord::Base
    end

    def save(record)
      Lead.create(record)
    end

    def all
      Lead.all
    end
  end
end
