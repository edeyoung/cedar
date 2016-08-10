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
                 measures: {
                   tags: ['Hospital'],
                   include: ['40280381-4B9A-3825-014B-C2730E6F088C', 'CMS117v4', 'CMS100V2'],
                   exclude: %w(CMS9v4 CMS91v5)
                 },
                 validations: {
                   tags: ['Schema'],
                   include: %w(discharge_after_upload numer_greater_than_denom)
                 }
               }
             }
        assert_response :success
        data = json(response)
        measures = data['data']['attributes']['measures']
        validations = data['data']['attributes']['validations']
        assert_includes measures, 'CMS117v4'
        assert_includes measures, 'CMS75v4' # This is from 40280381-4B9A-3825-014B-C2730E6F088C in the measures include
        refute_includes measures, 'CMS9v4'
        refute_includes measures, 'CMS100v2'
        assert_includes validations, 'discharge_after_upload'
        refute_includes validations, 'numer_greater_than_denom'
        assert_not_nil data['meta']['filtered']
      end

      test 'create test with all' do
        post :create,
             data: {
               attributes: {
                 name: 'all',
                 reporting_period: '2016',
                 qrda_type: '1',
                 measures: { all: true },
                 validations: { all: true }
               }
             }
        assert_response :success
      end

      test 'create invalid test' do
        post :create,
             data: {
               attributes: {
                 name: 'incompatible measure and validation',
                 reporting_period: '2016',
                 qrda_type: '3',
                 measures: { include: ['CMS55v4'] },
                 validations: { include: ['numer_greater_than_denom'] }
               }
             }
        assert_response 400
      end

      test 'delete test' do
        delete :destroy, id: @te.id
        assert_response :success
        assert_empty TestExecution.where(id: @te.id).documents
      end
    end
  end
end
