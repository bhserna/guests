require_relative "../lib/lists.rb"

RSpec.describe "Show all lists of user" do
  class FakeStore
    def initialize(records)
      @records = records
    end

    def find_all_by_user_id(user_id)
      @records.select { |r| r[:user_id] == user_id }
    end
  end

  def lists_of_user(user_id, store)
    Lists.lists_of_user(user_id, store)
  end

  def list_with(data)
    data
  end

  def store_with(records)
    FakeStore.new(records)
  end

  it "has all the records for the current user" do
    user_id = "1234"
    store = store_with([
      list_with(list_id: 1, user_id: "1234", name: "Uno"),
      list_with(list_id: 2, user_id: "1234", name: "Dos"),
      list_with(list_id: 3, user_id: "other", name: "Tres")
    ])

    first, second = lists_of_user(user_id, store)
    expect(first.id).to eq 1
    expect(first.name).to eq "Uno"

    expect(second.id).to eq 2
    expect(second.name).to eq "Dos"
  end
end
