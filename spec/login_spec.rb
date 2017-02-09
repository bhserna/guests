require_relative "../lib/users.rb"

RSpec.describe "Login user" do
  module FakeEncryptor
    def self.password?(hash, password)
      hash == "---encripted--#{password}--"
    end
  end

  class FakeStore
    def initialize(records)
      @records = records
    end

    def find_by_email(email)
      @records.detect { |r| r[:email] == email }
    end
  end

  module DummySessionStore
    def self.save_user_id(id)
    end
  end

  def login_form
    Users.login_form
  end

  def login(data, store)
    Users.login(data, store, FakeEncryptor, DummySessionStore)
  end

  def session_store
    DummySessionStore
  end

  def store
    FakeStore.new([{
      id: "j-id-1234",
      email: "j@example.com",
      password_hash: "---encripted--1234secret--"
    }])
  end

  it "has a form" do
    form = login_form
    expect(form.email).to eq nil
    expect(form.password).to eq nil
  end

  describe "with good data" do
    attr_reader :data

    before do
      @data = {
        "email" => "j@example.com",
        "password" => "1234secret"
      }
    end

    it "stores user id on session store" do
      expect(session_store)
        .to receive(:save_user_id)
        .with("j-id-1234")
      login(data, store)
    end

    it "returns success" do
      response = login(data, store)
      expect(response).to be_success
    end
  end

  describe "with a not registered email" do
    attr_reader :data

    before do
      @data = {
        "email" => "not found",
        "password" => nil
      }
    end

    it "does not saves a user id" do
      expect(session_store).not_to receive(:success)
      login(data, store)
    end

    it "does not returns success" do
      response = login(data, store)
      expect(response).not_to be_success
    end

    it "returns an error" do
      response = login(data, store)
      expect(response.error).to eq "Email o contraseña inválidos"
    end
  end

  describe "with an invalid password" do
    attr_reader :data

    before do
      @data = {
        "email" => "j@example.com",
        "password" => "invalid"
      }
    end

    it "does not saves a user id" do
      expect(session_store).not_to receive(:success)
      login(data, store)
    end

    it "does not returns success" do
      response = login(data, store)
      expect(response).not_to be_success
    end

    it "returns an error" do
      response = login(data, store)
      expect(response.error).to eq "Email o contraseña inválidos"
    end
  end
end
