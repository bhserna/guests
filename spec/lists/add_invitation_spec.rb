require_relative "../lists_spec"

module Lists
  describe "Add invitation" do
    it "creates a record" do
      store = FakeInvitationsStore.new
      list_id = 1234
      params = {
        "title" => "Uno",
        "guests" => [
          {"id" => 1, "name" => "Benito"},
          {"id" => 2, "name" => "Maripaz"}],
        "phone" => "1234-1234",
        "email" => "bh@example.com"
      }

      expect(store).to receive(:create).with({
        list_id: list_id,
        title: "Uno",
        guests: [{id: 1, name: "Benito"}, {id: 2, name: "Maripaz"}],
        phone: "1234-1234",
        email: "bh@example.com"
      })

      Lists.add_invitation(list_id, params, store)
    end
  end
end
