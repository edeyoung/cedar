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
    byebug
    @cat_1_file = IO.read('spec/fixtures/qrda/cat_1/good.xml')
    @cat_3_file = IO.read('spec/fixtures/qrda/cat_3/good.xml')
    setup_fixture_data
    # @user = create(:user)
    @header = { 'Accept' => 'application/vnd.api+json', 'Content-Type' => 'application/vnd.api+json' }
    byebug
    @request.env['devise.mapping'] = Devise.mappings[:user]
    # user = FactoryGirl.create(:user)
    # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
    # sign_in user
    # byebug

    @request.headers['Accept'] = 'application/vnd.api+json'
    @request.headers['Content-Type'] = 'application/vnd.api+json'
    @te = create(:te1)
    byebug
    # create(:te2)
    @user = @te.user
    # sign_in @user
  end

  xit 'create and get data flow' do
    # Get token
    post '/api/v1/users/sign_in', { email: @user.email, password: @user.password }.to_json, @header
    expect(response.body).to include('authentication_token')
    expect(response.body).to include('email')
    expect(response.content_type).to eq('application/json')
    expect(response).to have_http_status(:success)

    # Create a test execution, using test helper to process synchronously

    perform_enqueued_jobs do
      post '/api/v1/test_executions',
           { data: {
             attributes: {
               name: 'first',
               reporting_period: '2016',
               qrda_type: '1',
               measures: { include: ['40280381-4B9A-3825-014B-C2730E6F088c'] },
               validations: { include: ['discharge_after_upload'] }
             }
           } }.to_json, @header
    end
    expect(response).to have_http_status(:success)
    link = json(response)['data']['links']['self']
    assert_not_nil link
    assert_not_nil json(response)['data']['attributes']['file_path']

    get "#{link}/documents", {}, @header
    assert_response :success
    docnum = json(response)['data'].length

    # Bulk report results
    results = {}
    (0..docnum - 1).each do |i|
      results[i.to_s] = 'reject'
    end
    patch "#{link}/documents/report_results", { results: results }.to_json, @header
    expect(response).to have_http_status(:success)
  end

  it 'get documents' do
    byebug
    te = TestExecution.all.user(@user).first
    byebug
    get "/api/v1/test_executions/#{te.id}/documents", {}, @header
    expect(response).to have_http_status(:success)
    byebug
  end

  it 'show document' do
    te = TestExecution.all.user(@user).first
    get "/api/v1/test_executions/#{te.id}/documents/1", {}, @header
    expect(response).to have_http_status(:success)
    assert_equal json(response)['test_index'], 1
  end

  it 'update document result' do
    te = TestExecution.all.user(@user).first
    put "/api/v1/test_executions/#{te.id}/documents/1", { actual_result: 'reject' }.to_json, @header
    expect(response).to have_http_status(:success)
    assert_equal 'passed', json(response)['state']
  end
end
