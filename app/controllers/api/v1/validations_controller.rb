module API
  module V1
    class ValidationsController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      resource_description do
        short 'Test cases'
        formats ['json']
        header 'X-API-EMAIL', 'user\'s email', required: true
        header 'X-API-TOKEN', 'user\'s current authentication token', required: true
        description <<-EOS
        Validations used by Cedar.
        EOS
      end

      api! 'get all validations'
      def index
        render json: ValidationRepresenter.for_collection.new(Validation.all)
      end

      api! 'show single validation'
      def show
        respond_with Validation.find_by(code: params[:id])
      end
    end
  end
end
