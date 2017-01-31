require 'bcrypt'
require "active_record"

module Users
  module Encryptor
    def self.encrypt(password)
      BCrypt::Password.create(password)
    end
  end

  module Store
    class User < ActiveRecord::Base
    end

    def self.save(record)
      User.create(record)
    end

    def self.all
      User.all
    end
  end
end

module Leads
  module Store
    class Lead < ActiveRecord::Base
    end

    def self.save(record)
      Lead.create(record)
    end

    def self.all
      Lead.all
    end
  end
end
