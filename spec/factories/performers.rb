FactoryBot.define do
  factory :performer do
    name { Faker::Music.band }
  end
end
