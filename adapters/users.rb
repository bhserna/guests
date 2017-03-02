require 'bcrypt'

module Users
  module Encryptor
    def self.encrypt(password)
      BCrypt::Password.create(password)
    end

    def self.password?(hash, password)
      BCrypt::Password.new(hash) == password
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

    def self.find(id)
      User.find(id)
    end

    def self.find_by_email(email)
      User.find_by_email(email)
    end
  end

  class SessionStore
    def initialize(session)
      @session = session
    end

    def user_id
      session[:user_id]
    end

    def user_id?
      !!session[:user_id]
    end

    def save_user_id(id)
      session[:user_id] = id
    end

    def remove_user_id
      session[:user_id] = nil
    end

    private

    attr_reader :session
  end
end
