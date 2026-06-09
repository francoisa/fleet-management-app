FactoryBot.define do
  factory :vehicle do
    sequence(:license_plate) { |n| "ABC#{n}" }
    make { 'Toyota' }
    model { 'Camry' }
    year_of_manufacture { 2020 }
    vehicle_type { 'sedan' }
    sequence(:registration_number) { |n| "REG#{n}" }
    sequence(:chassis_number) { |n| "CHASSIS#{n}" }
    sequence(:serial_number) { |n| "SN#{n}" }
    agency { nil }
  end
end
