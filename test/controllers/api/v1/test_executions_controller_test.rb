require 'test_helper'

module API
  module V1
    class TestExecutionsControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods

      def setup
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
        @te = create(:te1)
        create(:te2)
        @user = @te.user
        sign_in @user
      end

      test 'show user\'s executions' do
        get :index
        assert_response :success
        executions = json(response)['data']
        assert executions.any?
      end

      test 'get execution' do
        get :show, id: @te.id
        assert_response :success
        assert_equal @te.name, json(response)['data']['attributes']['name']
      end

      # Note: Roar-rails is uncooperative with functional tests, so we can't test :create here.
      # Specifically, the consume! function reads from request.body, which is populated differently in tests.
      # One workaround is to use .to_json on parameters here, but then that fails the api-pie params validation.
    end
  end
end
