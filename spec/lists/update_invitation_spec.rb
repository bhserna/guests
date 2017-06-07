require_relative "../lists_spec"

module Lists
  describe "Updated invitation" do
    it "updates the record" do
      id = rand(100)
      store = FakeInvitationsStore.new({id: id})
      params = {
        "title" => "Uno",
        "guests" => [
          {"id" => 1, "name" => "Benito"},
          {"id" => 2, "name" => "Maripaz"}],
        "phone" => "1234-1234",
        "email" => "bh@example.com"
      }

      expect(store).to receive(:update).with(id, {
        title: "Uno",
        guests: [{id: 1, name: "Benito"}, {id: 2, name: "Maripaz"}],
        phone: "1234-1234",
        email: "bh@example.com"
      })

      Lists.update_invitation(id, params, store)
    end
  end
end
