module SeeAllWeddingRegistrations
  class WeddingRegistration
    attr_reader :first_name, :last_name, :email, :wedding_roll

    def initialize(data)
      @first_name = data[:first_name]
      @last_name = data[:last_name]
      @email = data[:email]
      @wedding_roll = data[:wedding_roll]
    end
  end

  class WeddingRegistrationToDisplay < SimpleDelegator
    def wedding_roll
      RegisterWedding::WEDDING_ROLLS.fetch(super.to_sym)
    end
  end

  def self.find_all(store)
    store.all
      .map { |record| WeddingRegistration.new(record) }
      .map { |registration| WeddingRegistrationToDisplay.new(registration) }
  end
end
