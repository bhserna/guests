module Lists
  module Store
    class List < ActiveRecord::Base
    end

    def self.save(record)
      List.create(record)
    end

    def self.find_all_by_user_id(user_id)
      List.where(user_id: user_id)
    end
  end
end
