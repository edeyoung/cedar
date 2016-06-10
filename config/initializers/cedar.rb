require 'cedar'
require 'health-data-standards'
require 'hqmf-parser'

Faker::Config.locale = 'en-US'

# Insert or update all valdations based on validations.json
validations_data = JSON.parse(File.read('lib/cedar/validations.json'))
validations_data.each do |val|
  Validation.find_or_create_by(code: val['code']).update(
    val['attributes'].each { |key, value| "#{key}: #{value}" }
  )
end
