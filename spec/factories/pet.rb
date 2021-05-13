FactoryBot.define do
  factory :pet do
    name { Faker::Name.first_name }
    tag { "Demo Tag" }
  end
end