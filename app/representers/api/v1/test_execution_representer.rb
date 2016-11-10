require 'roar/rails/json_api'

module API
  module V1
    class TestExecutionRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :test_executions

      has_many :documents do
        type :documents

        property :test_index, as: :id
        property :state
        # Note to self: this is a link for a client calling the api
        link :self do
          api_v1_test_execution_document_url(represented.test_execution.id, represented.test_index)
        end
      end

      link :self do
        api_v1_test_execution_url(represented.id)
      end

      property :id
      property :state
      property :qrda_progress
      property :name
      property :description
      property :reporting_period
      property :file_path
      property :qrda_type

      # Validations
      property :validations,
               render_filter: ->(input, _options) { input.map(&:code) },
               skip_parse: true

      # Measures

      property :measures,
               render_filter: ->(input, _options) { input.map(&:cms_id) },
               skip_parse: true
    end
  end
end
