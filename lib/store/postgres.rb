require "active_record"
require_relative "postgres/config"

module Store
  class Postgres
    class Leads
      class Lead < ActiveRecord::Base
      end

      def save(record)
        Lead.create(record)
      end

      def all
        Lead.all
      end
    end

    class WeddingRegistrations
      class WeddingRegistration < ActiveRecord::Base
      end

      def save(record)
        WeddingRegistration.create(record)
      end

      def all
        WeddingRegistration.all
      end
    end
  end
end
