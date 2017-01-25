module Store
  module InMemoryStore
    class WeddingRegistrations
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
  end
end
