require_relative "../../lib/users.rb"

RSpec.describe "User auth" do
  class FakeSessionStore
    def initialize(data)
      @user_id = data[:user_id]
    end

    def user_id?
      !!@user_id
    end
  end

  def session_store_with(data)
    FakeSessionStore.new(data)
  end

  def user?(data)
    Users.user?(session_store: session_store_with(data))
  end

  def guest?(data)
    Users.guest?(session_store: session_store_with(data))
  end

  it "knows if the user is logged in" do
    expect(user?(user_id: "1234")).to be
    expect(user?({})).not_to be
  end

  it "knows if the user is a guest" do
    expect(guest?(user_id: "1234")).not_to be
    expect(guest?({})).to be
  end
end
