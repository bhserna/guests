require_relative "validations"

module Lists
  class ErrorWithForm
    attr_reader :form

    def initialize(form)
      @form = form
    end

    def success?
      false
    end
  end

  class Success
    def self.success?
      true
    end
  end

  class List
    attr_reader :id, :name

    def initialize(data)
      @id = data[:list_id]
      @name = data[:name]
    end
  end

  require_relative "lists/list_creator"
  require_relative "lists/access_control"

  def self.new_list_form
    ListCreator.new_list_form
  end

  def self.create_list(*args)
    ListCreator.create_list(*args)
  end

  def self.lists_of_user(user_id, store)
    store.find_all_by_user_id(user_id).map { |record| List.new(record) }
  end

  def self.current_access_details(*args)
    AccessControl.current_access_details(*args)
  end

  def self.give_access_form
    AccessControl.give_access_form
  end

  def self.give_access_to_person(*args)
    AccessControl.give_access_to_person(*args)
  end
end
