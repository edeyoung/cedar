module API
  module V1
    class DocumentsController < API::V1::BaseController
      def index
        render json: te.documents
      end

      def show
        render json: te.documents[params[:id].to_i]
      end

      def update
        document = te.documents[params[:id].to_i]
        document.update_attribute(:actual_result, result_params)
        document.update_state
        render json: document
      end

      private

      def result_params
        params.require(:actual_result)
      end

      def te
        TestExecution.find(params[:test_execution_id])
      end
    end
  end
end
