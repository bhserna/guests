module Users
  def self.register_form
    Registration.form
  end

  def self.register_user(data, config)
    Registration.register_user(data, config)
  end

  def self.login_form
    Login.form
  end

  def self.login(data, config)
    Login.login(data, config)
  end

  def self.user?(config)
    config.fetch(:session_store).user_id?
  end

  def self.guest?(config)
    !config.fetch(:session_store).user_id?
  end

  module Login
    def self.form
      Form.new
    end

    def self.login(data, store:, encryptor:, session_store:)
      return Error unless user = find_user(data, store)
      return Error unless valid_password?(data, user, encryptor)
      session_store.save_user_id(user[:id])
      Success
    end

    def self.find_user(data, store)
      store.find_by_email(data["email"])
    end

    def self.valid_password?(data, user, encryptor)
      encryptor.password?(user[:password_hash], data["password"])
    end

    module Error
      def self.success?
        false
      end

      def self.error
        "Email o contraseña inválidos"
      end
    end

    module Success
      def self.success?
        true
      end
    end

    class Form
      attr_reader :email, :password

      def initialize(data = {})
        @email = data[:email]
        @password = data[:password]
      end
    end
  end

  module Registration
    def self.form
      Form.new
    end

    def self.register_user(data, store:, encryptor:, session_store:)
      form = Form.new(data)
      errors = Validator.new(form).errors
      return (form.add_errors(errors) and Error.new(form)) if errors.any?
      user = create_record(form, store, encryptor)
      session_store.save_user_id(user[:id])
      Success
    end

    def self.create_record(form, store, encryptor)
      store.save(
        first_name: form.first_name,
        last_name: form.last_name,
        email: form.email,
        user_type: form.user_type,
        password_hash: encryptor.encrypt(form.password)
      )
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

    module Success
      def self.success?
        true
      end
    end

    class Validator
      def initialize(form)
        @form = form
      end

      def errors
        [validate_confirmation,
         *validate_presense_of(form.fields)].compact.to_h
      end

      private

      attr_reader :form

      def validate_confirmation
        unless form.password == form.password_confirmation
          [:password_confirmation, "no coincide"]
        end
      end

      def validate_presense_of(attrs)
        attrs.map do |attr|
          value = form.send(attr)
          message = "no puede estar en blanco"
          [attr, message] if value.nil? || value.empty?
        end
      end
    end

    class Form
      ATTRS = [:first_name, :last_name, :email, :user_type, :password, :password_confirmation]
      attr_reader *ATTRS
      attr_reader :errors

      def initialize(data = {})
        assign_attributes(data)
        @errors = {}
      end

      def fields
        ATTRS
      end

      def add_errors(errors)
        @errors = errors
      end

      def user_type_options
        [{value: :groom, text: "Novio"},
         {value: :bride, text: "Novia"},
         {value: :wedding_planner, text: "Wedding planner"},
         {value: :other, text: "Otro"}]
      end

      private

      attr_writer *ATTRS

      def assign_attributes(data)
        ATTRS.each do |attr|
          send("#{attr}=", data[attr.to_s])
        end
      end
    end
  end
end
