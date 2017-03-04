require_relative "../../lib/users.rb"

RSpec.describe "Sign out" do
  module DummySessionStore
    def self.remove_user_id
    end
  end

  def sign_out
    Users.sign_out(session_store: DummySessionStore)
  end

  def session_store
    DummySessionStore
  end

  it "removes the user id on session store" do
    expect(session_store).to receive(:remove_user_id)
    sign_out
  end
end
