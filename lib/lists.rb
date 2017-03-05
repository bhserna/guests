require_relative "validations"

module Lists
  def self.new_list_form
    Form.new
  end

  def self.create_list(user_id, data, store, id_generator)
    form = Form.new(data)
    errors = Validator.validate(form)

    if errors.empty?
      store.save(
        list_id: id_generator.generate_id,
        user_id: user_id,
        name: data["name"])
      Success
    else
      form.add_errors(errors)
      Error.new(form)
    end
  end

  def self.lists_of_user(user_id, store)
    store.find_all_by_user_id(user_id).map { |record| List.new(record) }
  end

  def self.current_access_details(list_id, store)
    ListAccessDetails.new(store.find_by_list_id(list_id))
  end

  def self.give_access_form
    GiveAccessForm.new
  end

  def self.give_access_to_person(list_id, person_params, store)
    current = current_access_details(list_id, store).people_with_access
    people = current + [PersonWithAccess.new(person_params)]
    store.update(list_id, people_with_access: people.map(&:to_h))
  end

  WEDDING_ROLL_OPTIONS = {
    groom: "Novio",
    bride: "Novia",
    wedding_planner: "Wedding planner",
    other: "Otro"
  }

  class ListAccessDetails
    attr_reader :people_with_access

    def initialize(data)
      @list = List.new(data)
      @people_with_access = build_people_with_access(data[:people_with_access])
    end

    def list_id
      list.id
    end

    def list_name
      list.name
    end

    private

    attr_reader :list

    def build_people_with_access(people_data)
      (people_data || []).map do |person_data|
        WeddingRollDecorator.new(PersonWithAccess.new(person_data))
      end
    end
  end

  class GiveAccessForm
    attr_reader :first_name, :last_name, :email, :wedding_roll

    def wedding_roll_options
      WEDDING_ROLL_OPTIONS.map do |value, text|
        {value: value, text: text}
      end
    end
  end

  class WeddingRollDecorator < SimpleDelegator
    def wedding_roll
      WEDDING_ROLL_OPTIONS[super.to_sym]
    end
  end

  class PersonWithAccess
    attr_reader :email, :wedding_roll

    def initialize(data)
      @first_name = get_value(data, :first_name)
      @last_name = get_value(data, :last_name)
      @email = get_value(data, :email)
      @wedding_roll = get_value(data, :wedding_roll)
    end

    def name
      "#{first_name} #{last_name}"
    end

    def to_h
      [:first_name, :last_name, :email, :wedding_roll]
        .map { |key| [key, send(key)] }
        .to_h
    end

    private

    attr_reader :first_name, :last_name

    def get_value(data, key)
      data[key.to_sym] || data[key.to_s]
    end
  end

  class List
    attr_reader :id, :name

    def initialize(data)
      @id = data[:list_id]
      @name = data[:name]
    end
  end

  class Error
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

  class Form
    attr_reader :name, :errors

    def initialize(data = {})
      @name = data["name"]
      @errors = {}
    end

    def add_errors(errors)
      @errors = errors
    end
  end

  class Validator
    extend Validations

    def self.validate(form)
      [*validate_presense_of(form, :name)].compact.to_h
    end
  end
end
