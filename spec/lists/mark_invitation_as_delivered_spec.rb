require_relative "../lists_spec"

module Lists
  describe "Mark invitation as delivered" do
    it "updates the record" do
      id = rand(100)
      store = FakeInvitationsStore.new([{id: id}])
      expect(store).to receive(:update).with(id, {is_delivered: true})
      Lists.mark_invitation_as_delivered(id, store)
    end
  end
end
