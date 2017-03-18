require "securerandom"

module Lists
  module Store
    class List < ActiveRecord::Base
      serialize :people_with_access, Array
    end

    def self.save(record)
      List.create(record)
    end

    def self.update(list_id, attrs)
      find_by_list_id(list_id).update(attrs)
    end

    def self.find_all_by_user_id(user_id)
      List.where(user_id: user_id)
    end

    def self.find_by_list_id(token)
      List.find_by(list_id: token)
    end
  end

  module PeopleStore
    class ListPerson < ActiveRecord::Base
    end

    def self.find(id)
      ListPerson.find(id)
    end

    def self.find_all_with_list_id(list_id)
      ListPerson.where(list_id: list_id)
    end

    def self.create(attrs)
      ListPerson.create(attrs)
    end

    def self.update(id, attrs)
      ListPerson.update(id, attrs)
    end

    def self.delete(id)
      ListPerson.delete(id)
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
