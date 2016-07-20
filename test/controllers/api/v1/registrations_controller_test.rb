require 'test_helper'

module API
  module V1
    class RegistrationsControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods

      test 'create account' do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        post :create, attributes_for(:user)

        assert_response :success

        user = json(response)['user']
        assert_not_nil user['authentication_token']
      end
    end
  end
end
