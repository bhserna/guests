require_relative "../lists_spec"

module Lists
  RSpec.describe "Create list" do
    class DummyStore
      def self.save(data)
      end
    end

    class FakeIdGenerator
      def self.generate_id
        "gen-id-1234"
      end
    end

    def new_list_form
      Lists.new_list_form
    end

    def create_list(user_id, data, store)
      Lists.create_list(user_id, data, store, FakeIdGenerator)
    end

    it "has a form" do
      form = new_list_form
      expect(form.name).to eq nil
    end

    it "has no errors" do
      form = new_list_form
      expect(form.errors).to be_empty
    end

    describe "with good data" do
      attr_reader :data, :store, :user_id

      before do
        @store = DummyStore
        @data = {"name" => "Lista uno"}
        @user_id = "1234"
      end

      it "saves the list with the form data" do
        expect(store).to receive(:save)
          .with(list_id: "gen-id-1234", user_id: "1234", name: "Lista uno")
        create_list(user_id, data, store)
      end

      it "returns success" do
        response = create_list(user_id, data, store)
        expect(response).to be_success
      end
    end

    describe "without data" do
      attr_reader :data, :store, :user_id

      before do
        @store = DummyStore
        @data = {"name" => ""}
        @user_id = "1234"
      end

      it "does not creates the record" do
        expect(store).not_to receive(:save)
        create_list(user_id, data, store)
      end

      it "returns a blank name error" do
        response = create_list(user_id, data, store)
        expect(response.form.errors).to eq({
          name: "no puede estar en blanco"
        })
      end

      it "is not success" do
        response = create_list(user_id, data, store)
        expect(response).not_to be_success
      end
    end
  end
end
