module API
  module V1
    class TestExecutionsController < API::V1::BaseController
      before_action :authenticate_user!

      def index
        render json: TestExecution.all.user(current_user)
      end

      def create
        # params.require(
        #   [:name,
        #    :reporting_period,
        #    :qrda_type,
        #    measure_ids: [],
        #    validation_ids: []]
        # )
        te = TestExecution.create(test_execution_params)
        te.create_documents
        render json: { download: "#{request.host_with_port}/#{te.file_path}" }, status: 201
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
          validation_ids: [],
          documents_attributes: [:id, :name, :actual_result, :test_index]
        )
        filtered[:user_id] = current_user.id
        filtered[:measure_ids].map! { |hqmf| Measure.find_by(hqmf_id: hqmf.upcase).id }
        filtered
      end

      def convert_measure(hqmf_or_cms)
      end
    end
  end
end
