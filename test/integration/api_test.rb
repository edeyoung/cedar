require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  include FactoryGirl::Syntax::Methods
  include ActiveJob::TestHelper
  setup do
    @user = create(:user)
    @header = { 'Accept' => 'application/vnd.api+json', 'Content-Type' => 'application/vnd.api+json' }
  end

  test 'create and get data flow' do
    # Get token
    post '/api/v1/users/sign_in', { email: @user.email, password: @user.password }.to_json, @header
    userjson = json(response)['user']
    assert_response :success
    @header['X-API-EMAIL'] = userjson['email']
    @header['X-API-TOKEN'] = userjson['authentication_token']

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
    assert_response :success
    link = json(response)['data']['links']['self']
    assert_not_nil link
    assert_not_nil json(response)['data']['attributes']['file_path']

    get "#{link}/documents", {}, @header
    assert_response :success
    docnum = json(response)['data'].length

    # Bulk report results
    results = {}
    (0..docnum-1).each do |i|
      results[i.to_s] = 'reject'
    end
    patch "#{link}/documents/report_results", { results: results }.to_json, @header
    assert_response :success
  end
  #
  # test 'get documents' do
  #   te = TestExecution.all.user(@user).first
  #   get "/api/v1/test_executions/#{te.id}/documents", {}, @header
  #   assert_equal 200, response.status
  # end
  #
  # test 'show document' do
  #   te = TestExecution.all.user(@user).first
  #   get "/api/v1/test_executions/#{te.id}/documents/1", {}, @header
  #   assert_equal 200, response.status
  #   assert_equal json(response)['test_index'], 1
  # end
  #
  # test 'update document result' do
  #   te = TestExecution.all.user(@user).first
  #   put "/api/v1/test_executions/#{te.id}/documents/1", { actual_result: 'reject' }.to_json, @header
  #   assert_equal 200, response.status
  #   assert_equal 'passed', json(response)['state']
  # end
end
