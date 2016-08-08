require 'test_helper'

module API
  module V1
    class ValidationsControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods

      def setup
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
        sign_in create(:user)
      end

      test 'show all' do
        get :index, qrda_type: 3, measure_type: 'all', tag: 'Calculation'
        assert_response :success
        executions = json(response)['data']
        assert executions.any?
      end

      test 'get validation' do
        @v = Validation.all.first
        get :show, id: @v.code
        assert_response :success
        assert_equal @v.code, json(response)['data']['id']
      end
    end
  end
end
