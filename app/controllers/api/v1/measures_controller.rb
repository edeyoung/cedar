module API
  module V1
    class MeasuresController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      resource_description do
        short 'Test cases'
        formats ['json']
        header 'X-API-EMAIL', 'user\'s email', required: true
        header 'X-API-TOKEN', 'user\'s current authentication token', required: true
        description <<-EOS
        Measures used by Cedar, referred to by CMS id.
        EOS
      end

      api! 'get all measures'
      def index
        render json: MeasureRepresenter.for_collection.new(Measure.all.top_level.only(:tags, :cms_id, :name, :description, :hqmf_id))
      end

      api! 'show single measure'
      def show
        render json: MeasureRepresenter.new(Measure.find_by(cms_id: params[:id]))
      end
    end
  end
end