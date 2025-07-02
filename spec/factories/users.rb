FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    zipcode { "#{rand(10000..99999)}" } # Generate a valid 5-digit zipcode
    password { 'password123' }
    password_confirmation { 'password123' }
    token_version { 0 }
  end
end
