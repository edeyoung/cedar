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

      test 'create test' do
        post :create,
             data: {
               attributes: {
                 name: 'first',
                 reporting_period: '2016',
                 qrda_type: '1',
                 measures: ['40280381-3D61-56A7-013e-6649110743ce'],
                 validations: ['discharge_after_upload']
               }
             }
        assert_response :success
      end

      test 'delete test' do
        delete :destroy, id: @te.id
        assert_response :success
        assert_empty TestExecution.where(id: @te.id).documents
      end
    end
  end
end
