require "securerandom"

module Lists
  module Store
    class List < ActiveRecord::Base
      serialize :people_with_access, Array
    end

    def self.save(record)
      List.create(record)
    end

    def self.find_all_by_user_id(user_id)
      List.where(user_id: user_id)
    end

    def self.find_by_list_id(token)
      List.find_by(list_id: token)
    end
  end

  module IdGenerator
    def self.generate_id
      token = SecureRandom.uuid

      if Store.find_by_list_id(token)
        generate_id
      else
        token
      end
    end
  end
end
