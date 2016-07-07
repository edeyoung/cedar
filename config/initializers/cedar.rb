require 'cedar'
require 'health-data-standards'
require 'hqmf-parser'

Faker::Config.locale = 'en-US'
APP_CONFIG = YAML.load(File.read(File.expand_path('../cedar.yml', __FILE__)))

# Insert or update all valdations based on validations.json
validations_data = JSON.parse(File.read('lib/cedar/validations.json'))
validations_data.each do |new_val|
  begin
    val = Validation.find_by(code: new_val['code'])
    new_val['attributes'].each do |key, value|
      case key
      when 'tags'
        unless new_val['attributes']['tags'].nil?
          # Respect any user-added tags and add the ones in the validations.json file
          val.update_attribute(:tags, (val.tags + new_val['attributes']['tags']).uniq)
        end
      else
        val.update_attribute(key, value)
      end
    end
  rescue
    Validation.where(code: new_val['code']).first_or_create(
      new_val['attributes'].each do |key, value|
        "#{key}: #{value}"
      end
    )
  end
end

# Add tags to measures based on measures.json
measures_data = JSON.parse(File.read('lib/cedar/measure_tags.json'))
measures_data.each do |measure|
  begin
    existing_measure = Measure.find_by(id: measure['id'])
    existing_measure.update_attribute(:tags, (existing_measure.tags + measure['tags']).uniq)
  rescue
    'Nope'
  end
end
