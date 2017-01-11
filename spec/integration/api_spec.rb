require 'rails_helper'
require 'fileutils'
require 'nokogiri'
require 'rspec/expectations'

# Unit test cases for all of the Cedar invalidators
RSpec.describe 'API Integration Tests: ', type: 'request' do
  include RSpec::Matchers
  include ActiveJob::TestHelper
  # include Devise::Test::ControllerHelpers
  # include FactoryGirl::Syntax::Methods
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:authed_user) { create_logged_in_user }

  def create_logged_in_user
    @a_user = FactoryGirl.create(:user)
    login(@a_user)
    @a_user
  end

  def login(user)
    login_as user, scope: :user
  end

  before(:each) do
    @cat_1_file = IO.read('spec/fixtures/qrda/cat_1/good.xml')
    @cat_3_file = IO.read('spec/fixtures/qrda/cat_3/good.xml')
    setup_fixture_data
    # @user = create(:user)
    @header = { 'Accept' => 'application/vnd.api+json', 'Content-Type' => 'application/vnd.api+json' }
    # @request.env['devise.mapping'] = Devise.mappings[:user]
    # user = FactoryGirl.create(:user)
    # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
    # sign_in user


    # @request.headers['Accept'] = 'application/vnd.api+json'
    # @request.headers['Content-Type'] = 'application/vnd.api+json'
    @te = create(:te1)
    # @user = @te.user
    # login(@user)
  end

  it 'create and get data flow' do
    a_user = create_logged_in_user

    expect(a_user.authentication_token).not_to be_empty
    post '/api/v1/users/sign_in', { email: a_user.email, password: a_user.password }, headers: @header
    expect(response.body).to include('email')
    expect(response.content_type).to eq('application/json')
    expect(response).to have_http_status(:success)
    expect(enqueued_jobs.size).to eq 0
    perform_enqueued_jobs do
      post '/api/v1/test_executions',
        data: {
          type: 'test_executions',
          attributes: {
            name: 'create test_execution',
            description: '',
            reporting_period: '2016',
            qrda_type: '1',
            measures: { include: ['40280381-446B-B8C2-0144-9EDB61C22CB1', '40280381-43DB-D64C-0144-64CB12982D97'] },
            # measures: { include: ['40280381-4B9A-3825-014B-C2730E6F088c'] },
            validations: { include: %w(discharge_before_admission incorrect_code_system) },
          }
        }
    end
    expect(enqueued_jobs.size).to eq 1
    expect(response).to have_http_status(:success)
    data_json = JSON.parse(response.body)
    link = data_json['data']['links']['self']
    expect(link).not_to be_empty
    get '/api/v1/test_executions/' + data_json['data']['id']
    data_json = JSON.parse(response.body)
    # TODO turn on create jobs path again
    # expect(data_json['data']['attributes']['file_path']).not_to be_empty
    # TODO This test does way too many things. Separate the following out into
    # new test
    # get "#{link}/documents", headers: @header
    # expect(response).to have_http_status(:success)
    # docnum = json(response)['data'].length
    #
    # # Bulk report results
    # results = {}
    # (0..docnum - 1).each do |i|
    #   results[i.to_s] = 'reject'
    # end
    # patch "#{link}/documents/report_results", params: { results: results }, headers: @header
    # expect(response).to have_http_status(:success)
  end

  it 'get documents' do
    te = TestExecution.all.user(@user).first
    get "/api/v1/test_executions/#{te.id}/documents", headers: @header
    expect(response).to have_http_status(:success)
    te = TestExecution.all.user(@user).first
    # test_executions = create_list(:te1, 5)
    get "/api/v1/test_executions/#{te.id}/documents", headers: @header
    expect(response).to have_http_status(:success)
  end

  it 'show document' do
    # te = TestExecution.all.user(@user).first
    # te = create(:te_with_10_docs)
    te = create(:te1)
    # te = create(:te1, :with_documents, doc_count: 10)
    get "/api/v1/test_executions/#{te.id}/documents/1", headers: @header
    expect(response).to have_http_status(:success)
    assert_equal json(response)['test_index'], 1
  end

  xit 'update document result' do
    te = TestExecution.all.user(@user).first
    put "/api/v1/test_executions/#{te.id}/documents/1", params: { actual_result: 'reject' }, headers: @header
    expect(response).to have_http_status(:success)
    assert_equal 'passed', json(response)['state']
  end
end
