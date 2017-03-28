require_relative "../lists_spec"

module Lists
  RSpec.describe "Access control" do
    def lists_store_with(records)
      FakeListsStore.new(records)
    end

    def people_store_with(records)
      FakePeopleWithAccessStore.new(records)
    end

    def user_with(attrs)
      Users.build_user(attrs.merge(id: SecureRandom.uuid))
    end

    it "has the list info" do
      list_id = "list-id-1234"
      list = {list_id: list_id, name: "Mi super lista"}
      lists_store = lists_store_with([list])
      people_store = people_store_with([])
      details = Lists.current_access_details(list_id, lists_store, people_store)
      expect(details.list_id).to eq list_id
      expect(details.list_name).to eq "Mi super lista"
    end

    describe "has access?" do
      attr_reader :list_id, :user, :email, :owner, :lists_store

      before do
        @email = "petro@example.com"
        @list_id = "list-id-1234"
        @user = user_with(email: email)
        @owner = user_with(email: "owner@example.com")
        list = {list_id: list_id, user_id: owner.id}
        @lists_store = lists_store_with([list])
      end

      def has_access?(user, list_id, people_store)
        Lists.has_access?(user, list_id, lists_store, people_store)
      end

      example "an empty list" do
        people_store = people_store_with([])
        expect(has_access?(user, list_id, people_store)).not_to be
      end

      example "with the owner of the list list" do
        people_store = people_store_with([])
        expect(has_access?(owner, list_id, people_store)).to be
      end

      example "with the user on the list" do
        people_store = people_store_with([{
          list_id: list_id,
          first_name: "Petronila",
          last_name: "Lozano",
          email: email,
          wedding_roll: "bride"
        }])
        expect(has_access?(user, list_id, people_store)).to be
      end

      example "without the user on the list" do
        other_user = user_with(email: "other@example.com")
        people_store = people_store_with([{
          list_id: list_id,
          first_name: "Petronila",
          last_name: "Lozano",
          email: email,
          wedding_roll: "bride"
        }])
        expect(has_access?(other_user, list_id, people_store)).not_to be
      end
    end


    describe "people with access" do
      def people_with_access(list_id, lists_store, people_store)
        Lists
          .current_access_details(list_id, lists_store, people_store)
          .people_with_access
      end

      describe "when no access has been given" do
        it "has an empty list" do
          list_id = "list-id-1234"
          list = {list_id: list_id, name: "Mi super lista"}
          lists_store = lists_store_with([list])
          people_store = people_store_with([])
          people = people_with_access(list_id, lists_store, people_store)
          expect(people).to be_empty
        end
      end

      describe "when one user has access" do
        it "has that user in the list" do
          list_id = "list-id-1234"
          list = {list_id: list_id}
          person = {
            list_id: list_id,
            first_name: "Petronila",
            last_name: "Lozano",
            email: "petro@example.com",
            wedding_roll: "bride"
          }

          lists_store = lists_store_with([list])
          people_store = people_store_with([person])
          people = people_with_access(list_id, lists_store, people_store)
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
          list = {list_id: list_id}
          people = [{
            list_id: list_id,
            first_name: "Petronila",
            last_name: "Lozano",
            email: "petro@example.com",
            wedding_roll: "bride"
          }, {
            list_id: list_id,
            first_name: "Hernan",
            last_name: "Perez",
            email: "hp@example.com",
            wedding_roll: "groom"
          }]

          lists_store = lists_store_with([list])
          people_store = people_store_with(people)
          people = people_with_access(list_id, lists_store, people_store)

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

    describe "give access to person" do
      describe "with good data" do
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

        it "creates a new person acceess in the store" do
          list = {list_id: list_id}
          lists_store = lists_store_with([list])
          people_store = people_store_with([])

          expect(people_store).to receive(:create).with({
            list_id: list_id,
            first_name: "Benito",
            last_name: "Serna",
            email: "b@e.com",
            wedding_roll: "groom"
          })

          Lists.give_access_to_person(list_id, person_params, people_store)
        end

        it "returns success" do
          list = {list_id: list_id}
          lists_store = lists_store_with([list])
          people_store = people_store_with([])
          response = Lists.give_access_to_person(list_id, person_params, people_store)
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
          list = {list_id: list_id}
          lists_store = lists_store_with([list])
          people_store = people_store_with([])
          response = Lists.give_access_to_person(list_id, person_params, people_store)
          expect(response).not_to be_success
        end

        it "returns the errors" do
          list = {list_id: list_id}
          lists_store = lists_store_with([list])
          people_store = people_store_with([])
          response = Lists.give_access_to_person(list_id, person_params, people_store)
          expect(response.form.errors[:first_name]).to eq "no puede estar en blanco"
          expect(response.form.errors[:last_name]).to eq "no puede estar en blanco"
          expect(response.form.errors[:email]).to eq "no puede estar en blanco"
          expect(response.form.errors[:wedding_roll]).to eq "no puede estar en blanco"
        end
      end
    end

    describe "edit access form" do
      it "has the right fields and wedding roll options" do
        list_id = "list-id-1234"

        groom = {
          id: "1234",
          list_id: list_id,
          first_name: "Benito",
          last_name: "Serna",
          email: "b@e.com",
          wedding_roll: "groom"
        }

        bride = {
          id: "2345",
          list_id: list_id,
          first_name: "Maripaz",
          last_name: "Moreno",
          email: "m@e.com",
          wedding_roll: "bride"
        }

        people_store = people_store_with([groom, bride])
        form = Lists.edit_access_form(groom[:id], people_store)

        expect(form.first_name).to eq "Benito"
        expect(form.last_name).to eq "Serna"
        expect(form.email).to eq "b@e.com"
        expect(form.wedding_roll).to eq "groom"
        expect(form.wedding_roll_options).to eq [
          {value: :groom, text: "Novio"},
          {value: :bride, text: "Novia"},
          {value: :wedding_planner, text: "Wedding planner"},
          {value: :other, text: "Otro"}
        ]
      end
    end

    describe "update access for person" do
      describe "updates the person on the list record" do
        attr_reader :list_id, :groom, :bride, :record, :person_params

        before do
          @list_id = "list-id-1234"

          @groom = {
            id: "1234",
            list_id: list_id,
            first_name: "Benito",
            last_name: "Serna",
            email: "b@e.com",
            wedding_roll: "groom"
          }

          @bride = {
            id: "2345",
            list_id: list_id,
            first_name: "Maripaz",
            last_name: "Moreno",
            email: "m@e.com",
            wedding_roll: "bride"
          }

          @person_params = {
            "first_name" => "Updated Benito",
            "last_name" => "Updated Serna",
            "email" => "b-updated@e.com",
            "wedding_roll" => "groom"
          }
        end

        example do
          people_store = people_store_with([groom, bride])
          expect(people_store).to receive(:update).with(groom[:id], {
            list_id: list_id,
            first_name: "Updated Benito",
            last_name: "Updated Serna",
            email: "b-updated@e.com",
            wedding_roll: "groom"
          })

          Lists.update_access_for_person(groom[:id], person_params, people_store)
        end

        it "returns success" do
          people_store = people_store_with([groom, bride])
          response = Lists.update_access_for_person(groom[:id], person_params, people_store)
          expect(response).to be_success
        end
      end

      describe "without data" do
        attr_reader :groom, :record, :person_params

        before do
          @groom = {
            id: "1234",
            list_id: "list-id-1234",
            first_name: "Benito",
            last_name: "Serna",
            email: "b@e.com",
            wedding_roll: "groom"
          }

          @person_params = {}
        end

        it "does not return success" do
          people_store = people_store_with([groom])
          response = Lists.update_access_for_person(groom[:id], person_params, people_store)
          expect(response).not_to be_success
        end

        it "returns the errors" do
          people_store = people_store_with([groom])
          response = Lists.update_access_for_person(groom[:id], person_params, people_store)
          expect(response.form.errors[:first_name]).to eq "no puede estar en blanco"
          expect(response.form.errors[:last_name]).to eq "no puede estar en blanco"
          expect(response.form.errors[:email]).to eq "no puede estar en blanco"
          expect(response.form.errors[:wedding_roll]).to eq "no puede estar en blanco"
        end
      end
    end

    describe "remove access for person" do
      it "romoves the person from the list record" do
        groom = {
          id: "1234",
          list_id: "list-id-1234",
          first_name: "Benito",
          last_name: "Serna",
          email: "b@e.com",
          wedding_roll: "groom"
        }

        people_store = people_store_with([groom])
        expect(people_store).to receive(:delete).with(groom[:id])
        Lists.remove_access_for_person(groom[:id], people_store)
      end
    end
  end
end
