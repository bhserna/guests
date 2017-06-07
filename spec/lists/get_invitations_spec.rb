require_relative "../lists_spec"

module Lists
  describe "Get invitation" do
    it "asks for the record" do
      list_id = 1234
      store = FakeInvitationsStore.new([{
        list_id: 1234,
        id: 1,
        title: "Uno",
        guests: [
          {id: 1, name: "Benito"},
          {id: 2, name: "Maripaz"}],
        phone: "1234-1234",
        email: "bh@example.com",
        is_delivered: true,
        confirmed_guests_count: 2,
        is_assistance_confirmed: true
      }, {
        list_id: 1234,
        id: 2,
        title: "Dos",
        guests: [
          {id: 1, name: "Gus"},
          {id: 2, name: "Caro"}],
        phone: "11-1234-1234",
        email: "g@example.com",
        is_delivered: false,
        confirmed_guests_count: 0,
        is_assistance_confirmed: false
      }, {
        list_id: 1234,
        id: 3,
        is_deleted: true
      }, {
        list_id: 12,
        id: 4
      }])

      first, second = Lists.get_invitations(list_id, store)
      expect(first.id).to eq 1
      expect(first.title).to eq "Uno"
      expect(first.phone).to eq "1234-1234"
      expect(first.email).to eq "bh@example.com"
      expect(first).to be_delivered
      expect(first).to have_assistance_confirmed
      expect(first.confirmed_guests_count).to eq 2

      benito, maripaz = first.guests
      expect(benito.id).to eq 1
      expect(maripaz.id).to eq 2
      expect(benito.name).to eq "Benito"
      expect(maripaz.name).to eq "Maripaz"

      expect(second.id).to eq 2
      expect(second.title).to eq "Dos"
      expect(second.phone).to eq "11-1234-1234"
      expect(second.email).to eq "g@example.com"
      expect(second).not_to be_delivered
      expect(second).not_to have_assistance_confirmed
      expect(second.confirmed_guests_count).to eq 0

      gus, caro = second.guests
      expect(gus.id).to eq 1
      expect(caro.id).to eq 2
      expect(gus.name).to eq "Gus"
      expect(caro.name).to eq "Caro"
    end
  end
end
