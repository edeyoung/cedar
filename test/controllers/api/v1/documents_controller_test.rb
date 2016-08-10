require 'test_helper'

module API
  module V1
    class DocumentsControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods

      def setup
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
        @te = create(:te_with_documents)
        sign_in @te.user
      end

      test 'index gets documents in order' do
        get :index, test_execution_id: @te.id
        assert_response :success
        zeroeth = json(response)['data'][0]
        assert_equal '0', zeroeth['id'], '0th document in data should have id 0'
      end

      test 'index returns error when unfinished' do
        @te = create(:te1)
        sign_in @te.user
        get :index, test_execution_id: @te.id
        assert_response :missing
      end

      test 'show gets single document' do
        get :show, test_execution_id: @te.id, id: 0
        assert_response :success
        assert_not_nil json(response)['data']['attributes']['qrda']
      end

      test 'report correct result' do
        put :update, test_execution_id: @te.id, id: 0, actual_result: @te.documents[0].expected_result
        assert_response :success
        assert_equal 'passed', json(response)['data']['attributes']['state']
      end

      test 'bulk report' do
        patch :report_results, test_execution_id: @te.id,
                               results: {
                                 '0' => @te.documents[0].expected_result,
                                 '1' => @te.documents[1].expected_result
                               }
        assert_response :success
        assert_equal 'passed', json(response)['data'][0]['attributes']['state']
        @te.reload
        assert_equal :passed, @te.state, ''
      end
    end
  end
end
