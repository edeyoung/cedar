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
    measures { [Measure.find_by(cms_id: 'CMS109v4')] }
    validations { [Validation.find_by(code: 'duplicate_population_ids')] }
  end

  factory :te2, class: TestExecution do
    association :user, factory: :user2
    name 'test2'
    reporting_period '2016'
    qrda_type '1'
    measures { [Measure.find_by(cms_id: 'CMS126v2')] }
    validations { [Validation.find_by(code: 'discharge_after_upload')] }
  end
end
