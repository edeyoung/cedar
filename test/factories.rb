FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
  end

  factory :user2, class: User do
    email { Faker::Internet.email }
    password 'password'
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

  factory :document1, class: Document do
    name '0000 - DAmore-Dare'
    expected_result 'reject'
    state 'failed'
    qrda { IO.read('test/fixtures/qrda/cat_1/good.xml') }
    sequence(:test_index, 0)
    validation_id { Validation.find_by(code: 'discharge_after_upload').id }
    measure_id '40280381-3D61-56A7-013E-6649110743CE'
    test_execution ''
  end

  factory :te_with_documents, class: TestExecution do
    association :user, factory: :user2
    name 'test2'
    reporting_period '2016'
    qrda_type '1'
    measures { [Measure.find_by(cms_id: 'CMS126v2')] }
    validations { [Validation.find_by(code: 'discharge_after_upload')] }
    after(:create) do |te, _evaluator|
      create_list(:document1, 2, test_execution: te)
    end
  end
end
