module API
  module V1
    class MeasuresController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      def index
        render json: MeasureRepresenter.for_collection.new(Measure.all.top_level.only(:cms_id, :name, :description, :hqmf_id))
      end

      def show
        render json: MeasureRepresenter.new(Measure.find_by(cms_id: params[:id]))
      end
    end
  end
end
