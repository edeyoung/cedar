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

      api! 'get all validations with query strings'
      param :tag, String, desc: 'Only show validations that have this tag'
      param :qrda_type, %w(1 3 all), desc: 'Only show validations that operate on this qrda type'
      param :measure_type, %w(all discrete), desc: 'Only show validations compatible with this type of measure'
      description 'Returns validations that satisfy all query paramters, or all validations if no query string is given.'
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
