require_relative "../lib/lists.rb"
require_relative "../adapters"

RSpec.describe "Show all lists of user" do
  class FakeStore
    def initialize(records)
      @records = records
    end

    def find_all_by_user_id(user_id)
      @records.select { |r| r[:user_id] == user_id }
    end
  end

  def lists_of_user(store, session_store)
    Lists.lists_of_user(store, session_store)
  end

  def list_with(data)
    data
  end

  def session_store_with(session)
    Users::SessionStore.new(session)
  end

  def store_with(records)
    FakeStore.new(records)
  end

  it "has all the records for the current user" do
    session_store = session_store_with(user_id: "1234")
    store = store_with([
      list_with(user_id: "1234", name: "Uno"),
      list_with(user_id: "1234", name: "Dos"),
      list_with(user_id: "other", name: "Tres")
    ])

    first, second = lists_of_user(store, session_store)
    expect(first.name).to eq "Uno"
    expect(second.name).to eq "Dos"
  end
end
