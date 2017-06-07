require_relative "../lists_spec"

module Lists
  describe "Delete invitation" do
    it "updates the record" do
      id = rand(100)
      store = FakeInvitationsStore.new([{id: id}])
      expect(store).to receive(:update).with(id, {is_deleted: true})
      Lists.delete_invitation(id, store)
    end
  end
end
