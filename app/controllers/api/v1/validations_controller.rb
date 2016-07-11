module API
  module V1
    class ValidationsController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      def index
        render json: ValidationRepresenter.for_collection.new(Validation.all)
      end

      def show
        respond_with Validation.find_by(code: params[:id])
      end
    end
  end
end
