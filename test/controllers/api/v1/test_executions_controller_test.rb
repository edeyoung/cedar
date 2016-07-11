require 'test_helper'

module API
  module V1
    class TestExecutionsControllerTest < ActionController::TestCase
      include Devise::Test::ControllerHelpers
      include FactoryGirl::Syntax::Methods

      def setup
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @te = create(:te1)
        create(:te2)
        @user = @te.user
        sign_in @user
      end

      test 'executions should be current user' do
        get :index
        assert_response :success
        executions = json(response)
        assert executions.any?
        executions.each do |execution|
          assert_equal @user.id.to_s, execution['user_id']
        end
      end

      test 'create execution' do
        post :create, name: 'test1',
                      reporting_period: '2016',
                      qrda_type: '1',
                      measure_ids: ['40280381-3D61-56A7-013e-6649110743ce'],
                      validation_ids: ['discharge_after_upload']
        assert_response :success
      end

      test 'get execution' do
        get :show, id: @te.id
        assert_response :success
        assert_equal json(response)['name'], @te.name
      end
    end
  end
end
