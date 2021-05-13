require 'rails_helper'

RSpec.describe Pet, type: :model do
  let!(:pet_name) {
    Faker::Name.first_name
  }
  let(:pet_attributes) {
    {name: pet_name, tag: "Demo Tag"}
  }
  subject {
    described_class.new(pet_attributes)
  }
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(1).is_at_most(100) }
    it { should validate_length_of(:tag).is_at_least(0).is_at_most(100) }
    it { should allow_value(nil).for(:tag) }
    it { should allow_value("").for(:tag) }
  end

  it 'should check name' do
    subject.save!
    expect(subject.name).to eq(pet_name)
  end
  it 'should check tag' do
    subject.save!
    expect(subject.tag).to eq("Demo Tag")
  end
  it "should be invalid when the pet is not passed attributes" do
    expect(Pet.new).to be_invalid
  end

  it "should be valid when the pet is passed correct attributes" do
    expect(subject).to be_valid
  end

  it "should be invalid when name is nil" do
    subject.name = nil
    expect(subject).to be_invalid
  end

  it "should be invalid when name length is > 100" do
    subject.name = SecureRandom.hex(120)
    expect(subject).to be_invalid
  end

  it "should be return raise active record invalid error when name length is > 100" do
    subject.name = SecureRandom.hex(120)
    expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should be valid when tag is nil" do
    subject.tag = nil
    expect(subject).to be_valid
  end

  it "should be valid when tag is empty" do
    subject.tag = ""
    expect(subject).to be_valid
  end

  it 'should be invalid when tag length is > 100' do
    subject.tag = SecureRandom.hex(120)
    expect(subject).to be_invalid
  end

  it "should be return raise active record invalid error when tag length is > 100" do
    subject.tag = SecureRandom.hex(120)
    expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should be return raise active record invalid error when name is nil" do
    subject.name = nil
    expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

end
