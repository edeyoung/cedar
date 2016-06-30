require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  setup do
    user = User.where(email: 'djchu@mitre.org').first
    user = User.create!(email: 'djchu@mitre.org', password: 'password') unless user
    @email = user.email
    @token = user.authentication_token
    @header = { 'X-API-EMAIL' => @email, 'X-API-TOKEN' => @token, 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
  end

  test 'sign up' do
    user = User.where(email: 'signuptest@gmail.com')
    user.destroy if user
    post '/api/v1/users', { email: 'signuptest@gmail.com', password: 'password' }.to_json,
         'Content-Type' => Mime::JSON.to_s, 'Accept' => Mime::JSON
    assert response.success?
    json_response = json(response)['user']
    email = json_response['email']
    token = json_response['authentication_token']
    assert_not_nil email
    assert_not_nil token
  end

  test 'sign in' do
    post '/api/v1/users/sign_in', { email: 'djchu@mitre.org', password: 'password' }.to_json,
         'Content-Type' => Mime::JSON.to_s, 'Accept' => Mime::JSON

    assert response.success?
    json_response = json(response)['user']
    email = json_response['email']
    token = json_response['authentication_token']
    assert_equal email, @email
    assert_equal token, @token
  end

  test 'get all test executions' do
    get '/api/v1/test_executions', {}, @header
    assert response.success?
  end

  test 'create test execution' do
    post '/api/v1/test_executions',
         { name: 'test1',
           reporting_period: '2016',
           qrda_type: '1',
           measure_ids: ['40280381-4BE2-53B3-014B-E66BED0703D0'],
           validation_ids: ['576d697f3bb7527f0a44d693'] }.to_json, @header
    assert_not_nil json(response)['download']
  end

  test 'sign out' do
    delete '/api/v1/users/sign_out', {}, 'X-API-TOKEN' => @token, 'Accept' => Mime::JSON
    assert response.success?
    assert_not_same @token, User.find_by(email: @email).authentication_token
  end
end
