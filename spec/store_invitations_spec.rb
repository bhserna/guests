require_relative "../lib/invitations.rb"

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

      def find_for_list_by_invitation_id(list_id, id)
        find_for_list(list_id).detect { |record| record[:invitation_id] == id }
      end

      def find_for_list(list_id)
        @records.select { |record| record[:list_id] == list_id }
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
      original = {
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

      updated = original.merge("title" => "Updated")

      record = {
        id: "record-1234",
        list_id: 1234,
        invitation_id: 1,
        raw_data: original
      }

      store = FakeStore.new([record])

      expect(store).to receive(:update).with("record-1234", {
        list_id: 1234,
        invitation_id: 1,
        raw_data: updated
      })

      Invitations.update_record(1234, updated, store)
    end

    it "deletes a record" do
      invitation = {"id" => 1}
      record = {
        id: "record-1234",
        list_id: 1234,
        invitation_id: 1,
        raw_data: invitation
      }

      store = FakeStore.new([record])
      expect(store).to receive(:delete).with("record-1234")
      Invitations.delete_record(1234, 1, store)
    end

    it "fetches all records" do
      first = {
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

      second = {
        "id" => 2,
        "title" => "Dos",
        "guests" => [
          {"id" => 1, "name" => "Gus"},
          {"id" => 2, "name" => "Caro"}],
        "phone" => "11-1234-1234",
        "email" => "g@example.com",
        "isDelivered" => false,
        "confirmedGuestsCount" => 0,
        "isAssistanceConfirmed" => false
      }

      records = [{
        id: "record-1",
        list_id: 1234,
        invitation_id: 1,
        raw_data: first
      }, {
        id: "record-2",
        list_id: 1234,
        invitation_id: 2,
        raw_data: second
      }]

      store = FakeStore.new(records)
      fetched = Invitations.fetch_records(1234, store)
      expect(fetched).to eq [first, second]
    end
  end
end
