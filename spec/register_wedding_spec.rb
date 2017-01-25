require_relative "../lib/register_wedding.rb"

RSpec.describe "Register wedding" do
  class DummyStore
    def self.save(data)
    end
  end

  def store
    DummyStore
  end

  def register_wedding_form
    RegisterWedding.build_form
  end

  def register_wedding(data, store)
    RegisterWedding.register(data, store)
  end

  it "has a form" do
    form = register_wedding_form
    expect(form.first_name).to eq nil
    expect(form.last_name).to eq nil
    expect(form.email).to eq nil
    expect(form.wedding_roll).to eq nil
    expect(form.password).to eq nil
  end

  it "has some  wedding roll options" do
    form = register_wedding_form
    expect(form.wedding_roll_options).to eq [
      {value: :groom, text: "Novio"},
      {value: :bride, text: "Novia"},
      {value: :wedding_planner, text: "Wedding planner"},
      {value: :other, text: "Otro"}
    ]
  end

  describe "with good data" do
    attr_reader :data

    before do
      @data = {
        "first_name" => "Juanito",
        "last_name" => "Perez",
        "email" => "j@example.com",
        "wedding_roll" => "groom",
        "password" => "1234secret",
        "password_confirmation" => "1234secret"
      }
    end

    it "saves the wedding with the form data" do
      expect(store).to receive(:save).with(
        first_name: "Juanito",
        last_name: "Perez",
        email: "j@example.com",
        wedding_roll: "groom",
        password: "1234secret"
      )

      register_wedding(data, store)
    end

    it "returns success" do
      registration = register_wedding(data, store)
      expect(registration).to be_success
    end
  end

  describe "without data" do
    attr_reader :data

    before do
      @data = {
        "first_name" => "",
        "last_name" => nil,
        "email" => "",
        "wedding_roll" => nil,
        "password" => nil,
        "password_confirmation" => nil
      }
    end

    it "does not creates the record" do
      expect(store).not_to receive(:save)
      register_wedding(data, store)
    end

    it "returns errors for each field" do
      registration = register_wedding(data, store)
      expect(registration.form.errors).to eq({
        first_name: "no puede estar en blanco",
        last_name: "no puede estar en blanco",
        email: "no puede estar en blanco",
        wedding_roll: "no puede estar en blanco",
        password: "no puede estar en blanco"
      })
    end

    it "is not success" do
      registration = register_wedding(data, store)
      expect(registration).not_to be_success
    end
  end
end
