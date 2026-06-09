FactoryBot.define do
  factory :agency do
    sequence(:code) { |n| "AGENCY#{n}" }
    sequence(:name) { |n| "Test Agency #{n}" }
    theme { 'blue' }
  end
end
