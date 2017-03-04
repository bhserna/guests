require_relative "../../lib/leads.rb"

RSpec.describe "Register lead" do
  class DummyStore
    def self.save(data)
    end
  end

  def register_lead_form
    Leads.register_form
  end

  def register_lead(data, store)
    Leads.register_lead(data, store)
  end

  it "has a form" do
    form = register_lead_form
    expect(form.first_name).to eq nil
    expect(form.last_name).to eq nil
    expect(form.email).to eq nil
    expect(form.lead_type).to eq nil
  end

  it "has some lead options" do
    form = register_lead_form
    expect(form.lead_type_options).to eq [
      {value: :wedding_planner, text: "Wedding planner"},
      {value: :bride, text: "Novia"},
      {value: :groom, text: "Novio"},
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
        "lead_type" => "groom"
      }
    end

    it "saves the lead with the form data" do
      expect(store).to receive(:save).with(data)
      register_lead(data, store)
    end

    it "returns success" do
      registration = register_lead(data, store)
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
        "lead_type" => nil
      }
    end

    it "does not creates the record" do
      expect(store).not_to receive(:save)
      register_lead(data, store)
    end

    it "returns errors for each field" do
      registration = register_lead(data, store)
      expect(registration.form.errors).to eq({
        first_name: "no puede estar en blanco",
        last_name: "no puede estar en blanco",
        email: "no puede estar en blanco",
        lead_type: "no puede estar en blanco"
      })
    end

    it "is not success" do
      registration = register_lead(data, store)
      expect(registration).not_to be_success
    end
  end
end
