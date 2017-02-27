module Invitations
  def self.save_record(list_id, invitation, store)
    store.create(
      list_id: list_id,
      invitation_id: invitation["id"],
      raw_data: invitation)
  end

  def self.update_record(list_id, invitation, store)
    record = store.find_by_invitation_id(invitation["id"])
    store.update(record[:id],
      list_id: list_id,
      invitation_id: invitation["id"],
      raw_data: invitation)
  end
end

module Invitations
  describe "Store invitations" do
    class FakeStore
      def initialize(records = [])
        @records = records
      end

      def create(record)
        record[:id] = SecureRandom.uuid
        @records << record
      end

      def find_by_invitation_id(id)
        @records.detect { |record| record[:invitation_id] == id }
      end
    end

    it "save invitations" do
      store = FakeStore.new
      list_id = 1234
      invitation = {
        "id" => 1,
        "title" => "Uno",
        "guests" => [
          {"id" => 1, "name" => "Benito"},
          {"id" => 2, "name" => "Maripaz"}],
        "phone" => "1234-1234",
        "email" => "bh@example.com",
        "isDelivered" => true,
        "confirmedGuestsCount" => 2,
        "isAssistanceConfirmed" => true
      }

      expect(store).to receive(:create).with({
        list_id: list_id,
        invitation_id: invitation["id"],
        raw_data: invitation
      })

      Invitations.save_record(list_id, invitation, store)
    end

    it "updates a record" do
      invitation = {
        "id" => 1,
        "title" => "Uno",
        "guests" => [
          {"id" => 1, "name" => "Benito"},
          {"id" => 2, "name" => "Maripaz"}],
        "phone" => "1234-1234",
        "email" => "bh@example.com",
        "isDelivered" => true,
        "confirmedGuestsCount" => 2,
        "isAssistanceConfirmed" => true
      }

      updated = invitation.merge("title" => "Updated")

      record = {
        id: "record-1234",
        list_id: 1234,
        invitation_id: 1,
        invitation: invitation
      }

      store = FakeStore.new([record])

      expect(store).to receive(:update).with("record-1234", {
        list_id: 1234,
        invitation_id: 1,
        raw_data: updated
      })

      Invitations.update_record(1234, updated, store)
    end
  end
end
