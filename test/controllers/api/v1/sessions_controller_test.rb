require 'test_helper'

module API
  module V1
    class SessionsControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods
      setup do
        @user = create(:user)
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
      end

      test 'valid sign in' do
        post :create, email: @user.email, password: @user.password

        assert_response :success

        user = json(response)['user']
        assert_not_nil user['authentication_token']
      end

      test 'invalid sign in' do
        post :create, email: Faker::Internet.email, password: 'incorrect'
        assert_response :unauthorized
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
