require 'test_helper'

module API
  module V1
    class SessionsControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods
      setup do
        @user = User.where(email: 'djchu@mitre.org').first
        @user ||= User.create!(email: 'djchu@mitre.org', password: 'password')
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
      end

      test 'sign in' do
        post :create, { email: 'djchu@mitre.org', password: 'password' }, format: 'json'

        assert_response :success

        user = json(response)['user']
        assert_not_nil user['authentication_token']
      end

      test 'sign out' do
        token = @user.authentication_token
        @request.headers['X-API-TOKEN'] = token
        delete :destroy, {}

        assert_not_equal token, User.all.first.authentication_token
      end
    end
  end
end
