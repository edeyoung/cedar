require 'test_helper'

module API
  module V1
    class MeasuresControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods

      def setup
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
        sign_in create(:user)
      end

      test 'show all' do
        get :index, reporting_period: 2015, tags: 'Continuous'
        assert_response :success
        executions = json(response)['data']
        assert executions.any?
      end

      test 'get measure' do
        @m = Measure.all.first
        get :show, id: @m.cms_id
        assert_response :success
        assert_equal @m.cms_id, json(response)['data']['id']
      end
    end
  end
end
