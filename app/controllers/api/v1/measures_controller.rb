module API
  module V1
    class MeasuresController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      resource_description do
        short 'Clinical Quality Measures'
        formats ['json']
        header 'X-API-EMAIL', 'user\'s email', required: true
        header 'X-API-TOKEN', 'user\'s current authentication token', required: true
        description <<-EOS
        Measures used by Cedar, referred to by CMS id.
        EOS
      end

      api! 'get all measures'
      def index
        render json: MeasureRepresenter.for_collection.new(Measure.all.top_level.where(query_params)
        .only(:tags, :cms_id, :name, :description, :hqmf_id, :bundle_id))
      end

      api! 'show single measure'
      def show
        render json: MeasureRepresenter.new(Measure.find_by(cms_id: params[:id]))
      end

      private

      def query_params
        filtered = params.permit(:tags, :reporting_period)
        if filtered[:reporting_period]
          bundle = HealthDataStandards::CQM::Bundle.all.to_a.select { |b| BUNDLE_MAP.key(b.measure_period_start) == filtered[:reporting_period] }[0]
          filtered[:bundle_id] = bundle.id
          filtered.delete :reporting_period
        end
        filtered
      end
    end
  end
end
