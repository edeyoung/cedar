require 'rails_helper'
require 'fileutils'
require 'nokogiri'
require 'rspec/expectations'
# Unit test cases for all of the Cedar invalidators
RSpec.describe 'API Integration Tests: ', type: 'request' do
  include RSpec::Matchers
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
    # byebug

    # @request.headers['Accept'] = 'application/vnd.api+json'
    # @request.headers['Content-Type'] = 'application/vnd.api+json'
    @te = create(:te1)
    @user = @te.user
    login(@user)
  end

  it 'create and get data flow' do
    # Get token
    byebug
    post '/api/v1/users/sign_in', params: { email: @user.email, password: @user.password }, headers: @header

    byebug
    expect(response.body).to include('authentication_token')
    expect(response.body).to include('email')
    expect(response.content_type).to eq('application/json')
    expect(response).to have_http_status(:success)
    # perform_enqueued_jobs do
    post '/api/v1/test_executions',
         params: {
           data: {
             attributes: {
               name: 'first test',
               reporting_period: '2016',
               qrda_type: '3',
               measures: [Measure.where(cms_id: 'CMS155v1')],
               validations: Validation.where(code: 'duplicate_population_ids')
             }
           },
           email: @user.email,
           password: @user.password
         },
         headers: @header

    expect(response).to have_http_status(:success)
    link = json(response)['data']['links']['self']
    assert_not_nil link
    assert_not_nil json(response)['data']['attributes']['file_path']
    get "#{link}/documents", headers: @header
    expect(response).to have_http_status(:success)
    docnum = json(response)['data'].length

    # Bulk report results
    results = {}
    (0..docnum - 1).each do |i|
      results[i.to_s] = 'reject'
    end
    patch "#{link}/documents/report_results", params: { results: results }, headers: @header
    expect(response).to have_http_status(:success)
  end

  it 'get documents' do
    te = TestExecution.all.user(@user).first
    byebug
    get "/api/v1/test_executions/#{te.id}/documents", headers: @header
    expect(response).to have_http_status(:success)
    te = TestExecution.all.user(@user).first
    # test_executions = create_list(:te1, 5)
    # byebug
    get "/api/v1/test_executions/#{te.id}/documents", headers: @header
    expect(response).to have_http_status(:success)
  end

  it 'show document' do
    # te = TestExecution.all.user(@user).first
    # te = create(:te_with_10_docs)
    te = create(:te1)
    # te = create(:te1, :with_documents, doc_count: 10)
    byebug
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
