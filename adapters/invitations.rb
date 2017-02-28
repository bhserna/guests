module Invitations
  module Store
    class Invitation < ActiveRecord::Base
      serialize :raw_data
    end

    def self.create(record)
      Invitation.create(record)
    end

    def self.find_for_list(list_id)
      Invitation.where(list_id: list_id)
    end

    def self.find_for_list_by_invitation_id(list_id, id)
      Invitation.find_by(list_id: list_id, invitation_id: id)
    end

    def self.update(id, attrs)
      Invitation.update(id, attrs)
    end

    def self.delete(id, attrs)
      Invitation.delete(id)
    end
  end
end
