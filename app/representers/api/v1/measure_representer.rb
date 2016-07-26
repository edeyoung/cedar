require 'roar/rails/json_api'

module API
  module V1
    class MeasureRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :measures

      link :self do
        api_v1_measure_url(represented.cms_id)
      end

      property :name
      property :description
      property :cms_id, as: :id
      property :hqmf_id
      property :tags
    end
  end
end
