json.array!(@validations) do |validation|
  json.extract! validation, :id, :name, :code, :description, :overview_text, :qrda_type
  json.url validation_url(validation, format: :json)
end
