require_relative "validations"

module Lists
  def self.new_list_form
    Form.new
  end

  def self.create_list(data, store)
    form = Form.new(data)
    errors = Validator.validate(form)

    if errors.empty?
      store.save(name: data["name"])
      Success
    else
      form.add_errors(errors)
      Error.new(form)
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
