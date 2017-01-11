require 'roar/rails/json_api'

module API
  module V1
    class MeasureRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :measures

      # Note to self: this is a link for a client calling the api
      link :self do
        api_v1_measure_url(represented)
      end

      property :name
      property :description
      property :cms_id, as: :id
      property :hqmf_id
      property :tags
      property :reporting_period
    end
  end
end
