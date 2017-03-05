require_relative "../../lib/lists.rb"

RSpec.describe "Access control" do
  class FakeStore
    def initialize(records)
      @records = records
    end

    def update(id, attrs)
    end

    def find_by_list_id(id)
      @records.detect { |r| r[:list_id] == id }
    end
  end

  def store_with(records)
    FakeStore.new(records)
  end

  it "has the list info" do
    list_id = "list-id-1234"
    record = {list_id: list_id, name: "Mi super lista"}
    store = store_with([record])
    details = Lists.current_access_details(list_id, store)
    expect(details.list_id).to eq list_id
    expect(details.list_name).to eq "Mi super lista"
  end

  describe "people with access" do
    def people_with_access(list_id, store)
      Lists.current_access_details(list_id, store).people_with_access
    end

    describe "when no access has been given" do
      it "has an empty list" do
        list_id = "list-id-1234"
        record = {
          list_id: list_id,
          people_with_access: []
        }

        store = store_with([record])
        people = people_with_access(list_id, store)
        expect(people).to be_empty
      end
    end

    describe "when one user has access" do
      it "has that user in the list" do
        list_id = "list-id-1234"
        record = {
          list_id: list_id,
          people_with_access: [{
            first_name: "Petronila",
            last_name: "Lozano",
            email: "petro@example.com",
            wedding_roll: "bride"
        }]}

        store = store_with([record])
        people = people_with_access(list_id, store)
        person = people.first
        expect(people.count).to eq 1
        expect(person.name).to eq "Petronila Lozano"
        expect(person.email).to eq "petro@example.com"
        expect(person.wedding_roll).to eq "Novia"
      end
    end

    describe "when more than one user has access" do
      it "has those users in the list" do
        list_id = "list-id-1234"
        record = {
          list_id: list_id,
          people_with_access: [{
            first_name: "Petronila",
            last_name: "Lozano",
            email: "petro@example.com",
            wedding_roll: "bride"
          }, {
            first_name: "Hernan",
            last_name: "Perez",
            email: "hp@example.com",
            wedding_roll: "groom"
        }]}

        store = store_with([record])
        people = people_with_access(list_id, store)
        first = people[0]
        second = people[1]

        expect(people.count).to eq 2
        expect(first.name).to eq "Petronila Lozano"
        expect(first.email).to eq "petro@example.com"
        expect(first.wedding_roll).to eq "Novia"
        expect(second.name).to eq "Hernan Perez"
        expect(second.email).to eq "hp@example.com"
        expect(second.wedding_roll).to eq "Novio"
      end
    end
  end

  describe "form to add person" do
    it "has the right fields" do
      form = Lists.give_access_form
      expect(form.first_name).to eq nil
      expect(form.last_name).to eq nil
      expect(form.email).to eq nil
      expect(form.wedding_roll).to eq nil
    end

    it "has the wedding roll options" do
      form = Lists.give_access_form
      expect(form.wedding_roll_options).to eq [
        {value: :groom, text: "Novio"},
        {value: :bride, text: "Novia"},
        {value: :wedding_planner, text: "Wedding planner"},
        {value: :other, text: "Otro"}
      ]
    end
  end

  describe "send person information" do
    describe "adds the person to the list record" do
      attr_reader :list_id, :person_params

      before do
        @list_id = "list-id-1234"
        @person_params = {
          "first_name" => "Benito",
          "last_name" => "Serna",
          "email" => "b@e.com",
          "wedding_roll" => "groom"
        }
      end

      example do
        record = {
          list_id: list_id,
          people_with_access: []
        }

        store = store_with([record])
        expect(store).to receive(:update).with(list_id, people_with_access: [{
          first_name: "Benito",
          last_name: "Serna",
          email: "b@e.com",
          wedding_roll: "groom"
        }])

        Lists.give_access_to_person(list_id, person_params, store)
      end

      example do
        bride = {
          first_name: "Maripaz",
          last_name: "Moreno",
          email: "m@e.com",
          wedding_roll: "bride"
        }

        record = {
          list_id: list_id,
          people_with_access: [bride]
        }

        store = store_with([record])
        expect(store).to receive(:update).with(list_id, people_with_access: [bride, {
          first_name: "Benito",
          last_name: "Serna",
          email: "b@e.com",
          wedding_roll: "groom"
        }])

        Lists.give_access_to_person(list_id, person_params, store)
      end

      it "returns success" do
        record = {list_id: list_id, people_with_access: []}
        store = store_with([record])
        response = Lists.give_access_to_person(list_id, person_params, store)
        expect(response).to be_success
      end
    end

    describe "without data" do
      attr_reader :list_id, :person_params

      before do
        @list_id = "list-id-1234"
        @person_params = {}
      end

      it "does not return success" do
        record = {list_id: list_id, people_with_access: []}
        store = store_with([record])
        response = Lists.give_access_to_person(list_id, person_params, store)
        expect(response).not_to be_success
      end

      it "returns the errors" do
        record = {list_id: list_id, people_with_access: []}
        store = store_with([record])
        response = Lists.give_access_to_person(list_id, person_params, store)
        expect(response.form.errors[:first_name]).to eq "no puede estar en blanco"
        expect(response.form.errors[:last_name]).to eq "no puede estar en blanco"
        expect(response.form.errors[:email]).to eq "no puede estar en blanco"
        expect(response.form.errors[:wedding_roll]).to eq "no puede estar en blanco"
      end
    end
  end
end
