FactoryBot.define do
  factory :vote do
    association :user
    association :performer
  end
end
