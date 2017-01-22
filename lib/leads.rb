module Leads
  def self.register_form
    Form.new
  end

  def self.register_lead(data, store)
    form = Form.new(data)
    if form.errors.any?
      RegistrationError.new(form)
    else
      store.save(data)
      RegistrationSuccess.new
    end
  end

  class RegistrationError
    attr_reader :form

    def initialize(form)
      @form = form
    end

    def success?
      false
    end
  end

  class RegistrationSuccess
    def success?
      true
    end
  end

  class Form
    ATTRS = [:first_name, :last_name, :email, :lead_type]
    attr_reader *ATTRS

    def initialize(data = {})
      ATTRS.each do |attr|
        send("#{attr}=", data[attr.to_s])
      end
    end

    def errors
      validate_presense_of(ATTRS).compact.to_h
    end

    def lead_type_options
      [{value: :groom, text: "Novio"},
       {value: :bride, text: "Novia"},
       {value: :wedding_planner, text: "Wedding planner"},
       {value: :other, text: "Otro"}]
    end

    private

    attr_writer *ATTRS

    def validate_presense_of(attrs)
      attrs.map do |attr|
        value = send(attr)
        message = "no puede estar en blanco"
        [attr, message] if value.nil? || value.empty?
      end
    end
  end
end
