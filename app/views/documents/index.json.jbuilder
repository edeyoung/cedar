json.array!(@documents) do |document|
  json.extract! document, :id, :name, :expected_result, :actual_result
  json.url document_url(document, format: :json)
end
