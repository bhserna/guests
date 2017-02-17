require_relative "validations"

module Lists
  def self.new_list_form
    Form.new
  end

  def self.create_list(data, store)
    form = Form.new(data)

    if form.errors.empty?
      store.save(name: data["name"])
      Success
    else
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
    end

    def errors
      Validator.new(self).errors
    end
  end

  class Validator
    include Validations

    def initialize(form)
      @form = form
    end

    def errors
      [*validate_presense_of(form, :name)].compact.to_h
    end

    private

    attr_reader :form
  end
end
