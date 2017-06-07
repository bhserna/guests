require_relative "../lists_spec"

module Lists
  describe "Confirm invitation guests" do
    it "updates the record" do
      id = rand(100)
      store = FakeInvitationsStore.new([{id: id}])
      expect(store).to receive(:update).with(id, {is_assistance_confirmed: true, confirmed_guests_count: 3})
      Lists.confirm_invitation_guests(id, "3", store)
    end
  end
end
