module Lists
  module ListCreator
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
        ErrorWithForm.new(form)
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
end
