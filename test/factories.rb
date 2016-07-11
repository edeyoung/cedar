FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
  end

  factory :user2, class: User do
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
  end

  factory :te1, class: TestExecution do
    association :user, factory: :user
    name 'first test'
    reporting_period '2016'
    qrda_type '3'
    measure_ids %w(CMS109v4 CMS110v4)
    validation_ids %w(duplicate_population_ids missing_population_id)
  end

  factory :te2, class: TestExecution do
    association :user, factory: :user2
    name 'test2'
    reporting_period '2016'
    qrda_type '1'
    measure_ids ['40280381-3D61-56A7-013e-6649110743ce']
    validation_ids ['discharge_after_upload']
  end
end
