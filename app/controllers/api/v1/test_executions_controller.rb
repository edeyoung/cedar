module API
  module V1
    class TestExecutionsController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      resource_description do
        short 'Test cases'
        formats ['json']
        header 'X-API-EMAIL', 'user\'s email', required: true
        header 'X-API-TOKEN', 'user\'s current authentication token', required: true
        description <<-EOS
        Test Executions accept a set of measures and validations to create valid and
        invalid qrda data with.
        EOS
      end

      api! 'get all tests of current user'
      def index
        render json: TestExecutionRepresenter.for_collection.new(TestExecution.user(current_user))
      end

      api! 'get test'
      def show
        respond_with TestExecution.user(current_user).find(params[:id])
      end

      api! 'create new test'
      param :data, Hash, desc: 'Root level hash', required: true do
        param :attributes, Hash, desc: 'Properties to set', required: true do
          param :name, String, desc: 'Name of test', required: true
          param :description, String, desc: 'Description for this test'
          param :reporting_period, %w(2014 2015 2016), desc: 'Which year measures will be from', required: true
          param :qrda_type, %w(1 3),
                desc: '"1" or "3" for category 1 and category 3 QRDA data, measures, and validations, respectively',
                required: true
          param :measures, Array,
                of: String,
                desc: 'Array of measures to create qrda data with. Measures can be specified with either hqmf or cms ids',
                required: true
          param :validations, Array,
                of: String,
                desc: 'Array of validation to invalidate qrda data with. Validations are specified with their codes. Eg: "discharge_after_upload"',
                required: true
        end
      end
      def create
        te = TestExecution.new
        consume!(te)
        te.save!
        current_user.test_executions << te
        CreateDocumentsJob.perform_later(te)
        respond_with te, status: 200
      end

      # api! ''
      # def update
      #   test_execution = TestExecution.find(params[:test_execution_id])
      #   test_execution.update_attributes(test_execution_params)
      #   head :ok
      # end

      api! 'delete test'
      def destroy
        TestExecution.find(params[:id]).destroy
        render json: { message: 'Test execution deleted.' }, success: true, status: 200
      end

      private

      def test_execution_params
        filtered = params.permit(
          :user_id,
          :name,
          :description,
          :reporting_period,
          :qrda_type,
          measure_ids: [],
          validation_ids: []
        )
        filtered[:user_id] = current_user.id
        filtered[:measure_ids].map! { |paramid| convert_measure(paramid).id } if filtered[:measure_ids]
        filtered[:validation_ids].map! { |paramid| convert_validation(paramid).id } if filtered[:validation_ids]
        filtered
      end

      def convert_measure(hqmf_or_cms)
        newid = Measure.where(hqmf_id: hqmf_or_cms.upcase).first
        newid ||= Measure.where(cms_id: /^#{Regexp.escape(hqmf_or_cms)}$/i).first
        newid
      end

      def convert_validation(code)
        Validation.find_by(code: code.downcase)
      end
    end
  end
end
