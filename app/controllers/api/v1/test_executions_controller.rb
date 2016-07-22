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
          param :reporting_period, BUNDLE_MAP.keys, desc: 'Which year measures will be from', required: true
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
        # NOTE: Roar makes #consume! available, that is supposed to make this much easier
        # However, it does not play nice with controller tests and apipie example generation
        # Also, from_hash(params) would not work with application/vnd.api+json content-type if not for code in initializers/mime_types.rb
        TestExecutionRepresenter.new(te).from_hash(params)
        validate_test_execution(te)
        if @errors.any?
          render json: { errors: @errors }, status: 400
        else
          current_user.test_executions << te
          CreateDocumentsJob.perform_later(te)
          respond_with te, status: 200
        end
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

      def validate_test_execution(test_execution)
        @errors = []
        check_measure_year(test_execution)
        check_validation_measure_type(test_execution)
        check_validation_qrda_type(test_execution)
      end

      def check_measure_year(test_execution)
        bundle_id = test_execution.bundle.id
        invalid_measure_ids = test_execution.measures.select { |measure| measure.bundle_id != bundle_id }.map(&:cms_id)

        if invalid_measure_ids.any?
          @errors << {
            title: 'Incorrect Measure Reporting Period',
            detail: "Measures #{invalid_measure_ids.join(',')} are not in reporting period #{test_execution.reporting_period}"
          }
        end
      end

      def check_validation_measure_type(test_execution)
        measure_types = test_execution.selected_measure_types
        if !measure_types[:discrete]
          invalid = 'discrete'
          valid = 'continuous'
        elsif !measure_types[:continuous]
          invalid = 'continuous'
          valid = 'discrete'
        else
          return
        end
        invalid_validation_ids = test_execution.validations.select { |validation| validation.measure_type == invalid }.map(&:code)
        if invalid_validation_ids.any?
          @errors << {
            title: 'Incompatible Validations and Measures',
            detail: "All selected measures are #{valid}, but validations #{invalid_validation_ids.join(',')} are only for #{invalid} measures"
          }
        end
      end

      def check_validation_qrda_type(test_execution)
        qrda_type = test_execution.qrda_type
        invalid_validation_ids = test_execution.validations.select { |validation| validation.qrda_type != qrda_type }.map(&:code)
        if invalid_validation_ids.any?
          @errors << {
            title: 'Incorrect QRDA Type',
            detail: "Validations #{invalid_validation_ids.join(',')} are not QRDA cat #{qrda_type}"
          }
        end
      end

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
