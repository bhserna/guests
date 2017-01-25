require_relative "../lib/see_all_wedding_registrations"

RSpec.describe "See all wedding registrations" do
  RECORDS = [
    {
      first_name: "Juanito",
      last_name: "Perez",
      email: "j@example.com",
      wedding_roll: "groom"
    },
    {
      first_name: "Karla",
      last_name: "Ramirez",
      email: "k@example.com",
      wedding_roll: "bride"
    },
    {
      first_name: "Lorena",
      last_name: "Garza",
      email: "l@example.com",
      wedding_roll: "wedding_planner"
    },

  ]

  class FakeStore
    def initialize(records)
      @records = records
    end

    def all
      @records
    end
  end

  def all_wedding_registrations
    SeeAllWeddingRegistrations.find_all(FakeStore.new(RECORDS))
  end

  it "has all the registrations" do
    expect(all_wedding_registrations.count).to eq 3
  end

  it "has the registration data" do
    juanito, karla, lorena = all_wedding_registrations
    expect(juanito.first_name).to eq "Juanito"
    expect(juanito.last_name).to eq "Perez"
    expect(juanito.email).to eq "j@example.com"
    expect(juanito.wedding_roll).to eq "Novio"

    expect(karla.first_name).to eq "Karla"
    expect(karla.last_name).to eq "Ramirez"
    expect(karla.email).to eq "k@example.com"
    expect(karla.wedding_roll).to eq "Novia"

    expect(lorena.first_name).to eq "Lorena"
    expect(lorena.last_name).to eq "Garza"
    expect(lorena.email).to eq "l@example.com"
    expect(lorena.wedding_roll).to eq "Wedding planner"
  end
end
