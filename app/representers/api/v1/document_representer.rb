require 'roar/rails/json_api'

module API
  module V1
    class DocumentRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI
      # include Roar::Hypermedia
      type :documents

      link :self do
        api_v1_test_execution_document_url(represented.test_execution.id, represented.test_index)
      end

      property :name
      property :expected_result
      property :state
      property :qrda
      property :test_index, as: :id
      property :actual_result
    end
  end
end
