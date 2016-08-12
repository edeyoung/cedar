require 'roar/rails/json_api'

module API
  module V1
    class DocumentRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :documents

      link :self do
        api_v1_test_execution_document_url(represented.test_execution.id, represented.test_index)
      end

      property :test_index, as: :id
      property :expected_result
      property :actual_result, render_nil: true
      property :state
      property :measure_id,
               as: :measure
      property :validation_id,
               as: :validation,
               render_filter: ->(input, _options) { Validation.find(input).code if input }
      property :name
      property :qrda
    end
  end
end
