module RegisterWedding
  WEDDING_ROLLS = {
    groom: "Novio",
    bride: "Novia",
    wedding_planner: "Wedding planner",
    other: "Otro"
  }

  def self.build_form
    Form.new
  end

  def self.register(data, store)
    form = Form.new(data)

    if form.errors.any?
      Error.new(form)
    else
      store.save(form.data_without(:password_confirmation))
      Success.new
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
    def success?
      true
    end
  end

  class Form
    ATTRS = [:first_name, :last_name, :email, :wedding_roll, :password, :password_confirmation]

    attr_reader *ATTRS

    def initialize(data = {})
      assign_values(ATTRS, data)
    end

    def errors
      validate_presense_of ATTRS.reject {|attr| attr == :password_confirmation}
    end

    def wedding_roll_options
      WEDDING_ROLLS.map {|value, text| {value: value, text: text}}
    end

    def data_without(key)
      ATTRS
        .reject {|attr| attr == key}
        .map {|attr| [attr, send(attr)]}
        .to_h
    end

    private

    attr_writer *ATTRS

    def validate_presense_of(attrs)
      attrs.map do |attr|
        value = send(attr)
        message = "no puede estar en blanco"
        [attr, message] if value.nil? || value.empty?
      end.compact.to_h
    end

    def assign_values(attrs, data)
      attrs.each do |attr|
        send("#{attr}=", data[attr.to_s])
      end
    end
  end
end

