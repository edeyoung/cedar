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
    # association :document, factory: :document
    name 'first test'
    reporting_period '2016'
    qrda_type '3'
    measures { [Measure.where(cms_id: 'CMS155v1')] }
    validations { [Validation.where(code: 'duplicate_population_ids')] }
    ignore do
      doc_count 5
    end
    trait :with_documents do
      after(:create) do |te, evaluator|
        create_list(:document, evaluator.doc_count, test_execution: te)
      end
    end
  end

  factory :document, class: Document do
    expected_result 'reject'
    state 'failed'
    qrda { IO.read('test/fixtures/qrda/cat_1/good.xml') }
    sequence(:test_index) { |n| n.to_s }
    name { "000#{test_index} - DAmore-Dare" }
    # validation_id { [Validation.where(code: 'discharge_after_upload')] }
    measure_id '40280381-3D61-56A7-013E-6649110743CE'
  end

  factory :te2, class: TestExecution do
    association :user, factory: :user2
    name 'test2'
    reporting_period '2016'
    qrda_type '1'
    measures { [Measure.where(cms_id: 'CMS126v1')] }
    validations { [Validation.where(code: 'discharge_after_upload')] }
  end

  # factory :te_with_documents, class: TestExecution do
  #   association :user, factory: :user2
  #   name 'test2'
  #   reporting_period '2016'
  #   qrda_type '1'
  #   qrda_progress '100'
  #   measures { [Measure.where(cms_id: 'CMS126v2')] }
  #   validations { [Validation.where(code: 'discharge_after_upload')] }
  #   # after(:create) do |te, _evaluator|
  #   #   create_list(:document1, 2, te_with_documents: te)
  #   # end
  # end



  # factory :document1, class: Document do
  #   expected_result 'reject'
  #   state 'failed'
  #   qrda { IO.read('test/fixtures/qrda/cat_1/good.xml') }
  #   sequence(:test_index, 0)
  #   name { "000#{test_index} - DAmore-Dare" }
  #   validation_id { Validation.find_by(code: 'discharge_after_upload').id }
  #   measure_id '40280381-3D61-56A7-013E-6649110743CE'
  #   test_execution :te2
  # end
end
