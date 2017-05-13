require_relative "../lists_spec"

module Lists
  RSpec.describe "Get list" do
    def lists_store_with(records)
      FakeListsStore.new(records)
    end

    it "has the list info" do
      list_id = "list-id-1234"
      list = {list_id: list_id, name: "Mi super lista"}
      lists_store = lists_store_with([list])
      list = Lists.get_list(list_id, lists_store)
      expect(list.id).to eq list_id
      expect(list.name).to eq "Mi super lista"
    end
  end
end
