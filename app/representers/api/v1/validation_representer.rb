require 'roar/rails/json_api'

module API
  module V1
    class ValidationRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :validations

      link :self do
        api_v1_validation_url(represented.code)
      end

      property :code, as: :id
      property :description
      property :qrda_type
      property :measure_type
      property :tags
    end
  end
end
