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
    User.create
    association :user, factory: :user
    # association :document, factory: :document
    name 'first test'
    reporting_period '2015'
    qrda_type '3'
    measures { [Measure.where(cms_id: 'CMS155v1')] }
    validations { [Validation.where(code: 'duplicate_population_ids')] }
    transient do
      create_docs false
      doc_count 3
    end

    trait :with_documents do
      create_docs true
      factory :document1, class: Document do
        # association :te1
        # test_execution = create(:te2)
        expected_result 'reject'
        state 'failed'
        qrda { IO.read('test/fixtures/qrda/cat_1/good.xml') }
        sequence(:test_index, 0)
        name { "000#{test_index} - DAmore-Dare" }
        validation_id { Validation.find_by(code: 'discharge_after_upload').id }
        measure_id '40280381-3D61-56A7-013E-6649110743CE'
      end
      after(:create) do |te1, evaluator|
        create_list(:document1, evaluator.doc_count, test_execution: te1)
        # te.documents << build(:document1, test_execution: te)
      end
    end
  end
  factory :te2, class: TestExecution do
    User.create
    # association :user2
    name 'test2'
    reporting_period '2016'
    qrda_type '1'
    measures { [Measure.where(cms_id: 'CMS126v1')] }
    validations { [Validation.where(code: 'discharge_after_upload')] }
  end

  # factory :te_with_documents, class: TestExecution do
  #   User.create
  #   # association :user
  #   name 'test2'
  #   reporting_period '2016'
  #   qrda_type '1'
  #   qrda_progress '100'
  #   measures { [Measure.where(cms_id: 'CMS126v1')] }
  #   validations { [Validation.where(code: 'discharge_after_upload')] }
  #   transient do
  #     doc_count 1
  #   end
  #   before(:create) do |te, evaluator|
  #     te.documents << create(:document1, test_execution: te)
  #   end
  #   # before(:create) do |te_with_documents, _evaluator|
  #   #   create(:document1, test_execution: te_with_documents)
  #   # end
  # end

end
