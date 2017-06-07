module Lists
  class Invitation
    attr_reader :id, :title, :guests, :phone, :email, :confirmed_guests_count

    def initialize(data)
      @id = get_value(data, :id)
      @title = get_value(data, :title)
      @guests = build_guests(get_value(data, :guests))
      @phone = get_value(data, :phone)
      @email = get_value(data, :email)
      @is_delivered = get_value(data, :is_delivered)
      @confirmed_guests_count = get_value(data, :confirmed_guests_count)
      @is_assistance_confirmed = get_value(data, :is_assistance_confirmed)
    end

    def creation_data
      {title: title,
       phone: phone,
       email: email,
       guests: guests.map { |guest| {id: guest.id, name: guest.name}}}
    end

    def delivered?
      !!@is_delivered
    end

    def has_assistance_confirmed?
      !!@is_assistance_confirmed
    end

    private

    def build_guests(guests_data)
      (guests_data || []).map do |data|
        Guest.new(*get_values(data, :id, :name))
      end
    end

    def get_value(data, key)
      data[key] || data[key.to_s]
    end

    def get_values(data, *keys)
      keys.map {|key| get_value(data, key)}
    end

    class Guest
      attr_reader :id, :name

      def initialize(id, name)
        @id = id
        @name = name
      end
    end
  end
end
