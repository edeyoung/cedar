require 'roar/rails/json_api'

module API
  module V1
    class TestExecutionRepresenter < Roar::Decorator
      include Roar::JSON::JSONAPI
      type :test_executions

      has_many :documents do
        type :documents

        property :id
        property :state
        link :self do
          api_v1_test_execution_document_url(represented.test_execution.id, represented.test_index)
        end
      end

      link :self do
        api_v1_test_execution_url(represented)
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
      # THERE ARE TWO WAYS TO DO this
      # First is to render the validation collection through the has_and_belongs_to_many relation
      # Only output code property
      collection :validations, class: Validation do
        property :code
      end
      # Second way is to take the hidden validation_ids field from mongoDB and map to convert all to code
      property :validation_ids, as: :validations,
                                render_filter: ->(input, _options) { input.map { |id| Validation.find(id)[:code] } }
      # THIRD would be to keep another column in mongoDB with the original input

      # Measures
      property :api_measure_codes, as: :measures
    end
  end
end
