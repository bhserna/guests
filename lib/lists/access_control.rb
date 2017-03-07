module Lists
  module AccessControl
    def self.current_access_details(list_id, store)
      ListAccessDetails.new(store.find_by_list_id(list_id))
    end

    def self.give_access_form
      GiveAccessForm.new(PersonWithAccess.new)
    end

    def self.give_access_to_person(list_id, person_params, store)
      person = PersonWithAccess.new(person_params)
      errors = Validator.validate(person)

      if errors.empty?
        current = current_access_details(list_id, store).people_with_access
        people = current + [person]
        store.update(list_id, people_with_access: people.map(&:to_h))
        Success
      else
        form = GiveAccessForm.new(person)
        form.add_errors(errors)
        ErrorWithForm.new(form)
      end
    end

    def self.edit_access_form(list_id, id, store)
      GiveAccessForm.new(
        current_access_details(list_id, store)
        .people_with_access
        .detect { |person| person.id == id }
        .to_person
      )
    end

    def self.update_access_for_person(list_id, id, person_params, store)
      people = current_access_details(list_id, store).people_with_access.map(&:to_person)
      person = people.detect { |person| person.id == id }.update(person_params)
      errors = Validator.validate(person)

      if errors.empty?
        people = people.map { |p| p.id == person.id && person || p }
        store.update(list_id, people_with_access: people.map(&:to_h))
        Success
      else
        form = GiveAccessForm.new(person)
        form.add_errors(errors)
        ErrorWithForm.new(form)
      end
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

    class Validator
      extend Validations

      def self.validate(form)
        [*validate_presense_of(form, *form.to_h.keys)].compact.to_h
      end
    end

    class GiveAccessForm < SimpleDelegator
      attr_reader :errors

      def initialize(person)
        @errors = {}
        super(person)
      end

      def add_errors(errors)
        @errors = errors
      end

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

      def to_person
        __getobj__
      end
    end

    class PersonWithAccess
      attr_reader :id, :first_name, :last_name, :email, :wedding_roll

      def initialize(data = {})
        @id = get_value(data, :id) || SecureRandom.uuid
        @first_name = get_value(data, :first_name)
        @last_name = get_value(data, :last_name)
        @email = get_value(data, :email)
        @wedding_roll = get_value(data, :wedding_roll)
      end

      def name
        "#{first_name} #{last_name}"
      end

      def update(data)
        self.class.new(data.merge(id: id))
      end

      def to_h
        [:id, :first_name, :last_name, :email, :wedding_roll]
          .map { |key| [key, send(key)] }
          .to_h
      end

      private

      def get_value(data, key)
        data[key.to_sym] || data[key.to_s]
      end
    end
  end
end
