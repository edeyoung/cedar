module API
  module V1
    class TestExecutionsController < API::V1::BaseController
      def index
        render json: TestExecution.all.user(current_user)
      end

      def show
        render json: TestExecution.find(params[:id])
      end

      def create
        te = TestExecution.create(test_execution_params)
        te.create_documents
        render json: { download: "#{request.host_with_port}/#{te.file_path}" }, status: 201
      end

      def update
        test_execution = TestExecution.find(params[:test_execution_id])
        test_execution.update_attributes(test_execution_params)
        head :ok
      end

      def destroy
        TestExecution.find(params[:id]).destroy
        render json: { message: 'Test execution deleted.' }, success: true, status: 200
      end

      def report_results
        test_execution = TestExecution.find(params[:id])
        params[:results].each do |k, v|
          test_execution.documents[k.to_i].update_attribute(:actual_result, v)
        end
        head :ok
      end

      private

      def test_execution_params
        filtered = params.require(:test_execution).permit(
          :user_id,
          :name,
          :description,
          :reporting_period,
          :qrda_type,
          :results,
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
