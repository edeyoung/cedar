module API
  module V1
    class ValidationsController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      resource_description do
        short 'Errors Cedar Can Introduce'
        formats ['json']
        header 'X-API-EMAIL', 'user\'s email', required: true
        header 'X-API-TOKEN', 'user\'s current authentication token', required: true
        description <<-EOS
        Validations used by Cedar.
        EOS
      end

      api! 'get all validations'
      def index
        render json: ValidationRepresenter.for_collection.new(Validation.where(query_params))
      end

      api! 'show single validation'
      def show
        respond_with Validation.find_by(code: params[:id])
      end

      private

      def query_params
        params.permit(:qrda_type, :measure_type, :tags)
      end
    end
  end
end
