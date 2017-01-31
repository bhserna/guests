module Users
  def self.register_form
    Form.new
  end

  def self.register_user(data, store, encryptor)
    form = Form.new(data)

    if form.errors.any?
      RegistrationError.new(form)
    else
      store.save(
        first_name: form.first_name,
        last_name: form.last_name,
        email: form.email,
        user_type: form.user_type,
        password_hash: encryptor.encrypt(form.password)
      )
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
    ATTRS = [:first_name, :last_name, :email, :user_type, :password, :password_confirmation]
    attr_reader *ATTRS

    def initialize(data = {})
      ATTRS.each do |attr|
        send("#{attr}=", data[attr.to_s])
      end
    end

    def errors
      [validate_confirmation, *validate_presense_of(ATTRS)].compact.to_h
    end

    def user_type_options
      [{value: :groom, text: "Novio"},
       {value: :bride, text: "Novia"},
       {value: :wedding_planner, text: "Wedding planner"},
       {value: :other, text: "Otro"}]
    end

    private

    attr_writer *ATTRS

    def validate_confirmation
      unless password == password_confirmation
        [:password_confirmation, "no coincide"]
      end
    end

    def validate_presense_of(attrs)
      attrs.map do |attr|
        value = send(attr)
        message = "no puede estar en blanco"
        [attr, message] if value.nil? || value.empty?
      end
    end
  end
end
