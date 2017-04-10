require_relative "../lists_spec"

module Lists
  RSpec.describe "Show all lists of user" do
    def lists_of_user(user, lists_store, people_store)
      Lists.lists_of_user(user, lists_store, people_store)
    end

    def list_with(data)
      data
    end

    def user_with(attrs)
      Users.build_user(attrs)
    end

    def store_with(records)
      FakeListsStore.new(records)
    end

    def people_store_with(records)
      FakePeopleWithAccessStore.new(records)
    end

    it "has all the records for the current user" do
      user = user_with(id: "1234", email: "current@example.com")

      lists_store = store_with([
        list_with(list_id: 1, user_id: "1234", name: "Uno"),
        list_with(list_id: 2, user_id: "1234", name: "Dos"),
        list_with(list_id: 3, user_id: "other", name: "Tres")
      ])

      people_store = people_store_with([])

      first, second = lists_of_user(user, lists_store, people_store)
      expect(first.id).to eq 1
      expect(first.name).to eq "Uno"

      expect(second.id).to eq 2
      expect(second.name).to eq "Dos"
    end

    it "also has all the records that the user has access to" do
      user = user_with(id: "1234", email: "current@example.com")

      lists_store = store_with([
        list_with(list_id: 1, user_id: "other", name: "Uno"),
        list_with(list_id: 2, user_id: "other", name: "Dos"),
        list_with(list_id: 3, user_id: "other", name: "Tres")
      ])

      people_store = people_store_with([
        {list_id: 2, email: user.email},
        {list_id: 3, email: user.email}
      ])

      first, second = lists_of_user(user, lists_store, people_store)
      expect(first.id).to eq 2
      expect(first.name).to eq "Dos"

      expect(second.id).to eq 3
      expect(second.name).to eq "Tres"
    end

    it "has no repeated records" do
      user = user_with(id: "1234", email: "current@example.com")

      lists_store = store_with([
        list_with(list_id: 1, user_id: "1234", name: "Uno"),
      ])

      people_store = people_store_with([
        {list_id: 1, email: user.email},
      ])

      lists = lists_of_user(user, lists_store, people_store)
      first = lists.first

      expect(lists.count).to eq 1
      expect(first.id).to eq 1
      expect(first.name).to eq "Uno"
    end
  end
end
