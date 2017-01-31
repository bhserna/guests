require_relative "../lib/users.rb"

RSpec.describe "Register user" do
  class DummyStore
    def self.save(data)
    end
  end

  module FakeEncryptor
    def self.encrypt(password)
      "---encripted--#{password}--"
    end
  end

  def register_user_form
    Users.register_form
  end

  def register_user(data, store)
    Users.register_user(data, store, FakeEncryptor)
  end

  it "has a form" do
    form = register_user_form
    expect(form.first_name).to eq nil
    expect(form.last_name).to eq nil
    expect(form.email).to eq nil
    expect(form.user_type).to eq nil
    expect(form.password).to eq nil
    expect(form.password_confirmation).to eq nil
  end

  it "has some user options" do
    form = register_user_form
    expect(form.user_type_options).to eq [
      {value: :groom, text: "Novio"},
      {value: :bride, text: "Novia"},
      {value: :wedding_planner, text: "Wedding planner"},
      {value: :other, text: "Otro"}
    ]
  end

  describe "with good data" do
    attr_reader :data, :store

    before do
      @store = DummyStore
      @data = {
        "first_name" => "Juanito",
        "last_name" => "Perez",
        "email" => "j@example.com",
        "user_type" => "groom",
        "password" => "1234secret",
        "password_confirmation" => "1234secret"
      }
    end

    it "saves the user with the form data" do
      expect(store).to receive(:save).with(
        first_name: "Juanito",
        last_name: "Perez",
        email: "j@example.com",
        user_type: "groom",
        password_hash: "---encripted--1234secret--"
      )

      register_user(data, store)
    end

    it "returns success" do
      registration = register_user(data, store)
      expect(registration).to be_success
    end
  end

  describe "without data" do
    attr_reader :data, :store

    before do
      @store = DummyStore
      @data = {
        "first_name" => "",
        "last_name" => nil,
        "email" => "",
        "user_type" => nil,
        "password" => nil,
        "password_confirmation" => nil
      }
    end

    it "does not creates the record" do
      expect(store).not_to receive(:save)
      register_user(data, store)
    end

    it "returns errors for each field" do
      registration = register_user(data, store)
      expect(registration.form.errors).to eq({
        first_name: "no puede estar en blanco",
        last_name: "no puede estar en blanco",
        email: "no puede estar en blanco",
        user_type: "no puede estar en blanco",
        password: "no puede estar en blanco",
        password_confirmation: "no puede estar en blanco"
      })
    end

    it "is not success" do
      registration = register_user(data, store)
      expect(registration).not_to be_success
    end
  end

  describe "with bad password confirmation" do
    attr_reader :data, :store

    before do
      @store = DummyStore
      @data = {
        "first_name" => "Juanito",
        "last_name" => "Perez",
        "email" => "j@example.com",
        "user_type" => "groom",
        "password" => "1234secret",
        "password_confirmation" => "other"
      }
    end

    it "does not creates the record" do
      expect(store).not_to receive(:save)
      register_user(data, store)
    end

    it "returns errors for each field" do
      registration = register_user(data, store)
      expect(registration.form.errors).to eq({
        password_confirmation: "no coincide"
      })
    end

    it "is not success" do
      registration = register_user(data, store)
      expect(registration).not_to be_success
    end
  end
end
