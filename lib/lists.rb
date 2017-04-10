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
    attr_reader :id, :name, :user_id

    def initialize(data)
      @id = data[:list_id]
      @name = data[:name]
      @user_id = data[:user_id]
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

  def self.lists_of_user(user, lists_store, people_store)
    records = lists_store.find_all_by_user_id(user.id)
    list_ids = people_store.find_ids_of_lists_with_access_for_email(user.email)
    records = (records + lists_store.find_all_by_list_ids(list_ids)).uniq
    records.map { |record| List.new(record) }
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

  def self.edit_access_form(*args)
    AccessControl.edit_access_form(*args)
  end

  def self.update_access_for_person(*args)
    AccessControl.update_access_for_person(*args)
  end

  def self.remove_access_for_person(*args)
    AccessControl.remove_access_for_person(*args)
  end

  def self.has_access?(*args)
    AccessControl.has_access?(*args)
  end
end
