require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s
  end

  test 'sign in' do
    post :create, { email: 'djchu@mitre.org', password: 'password' }.to_json, format: 'json'

    puts response.body

    assert_equal 200, response.status

    user = JSON.parse(response.body)
    assert_not_nil user['auth_token']
  end
end
