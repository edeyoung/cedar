# Generates the measure_tags.json file.  Modify as necessary
measure_tags = []
Measure.all.each do |measure|
  measure_hash = {}
  measure_hash['id'] = measure.hqmf_id
  measure_hash['tags'] = []
  measure_hash['tags'] += case measure.type
                          when 'ep'
                            ['Provider']
                          when 'eh'
                            ['Hospital']
                          end
  measure_hash['tags'] += case measure.continuous_variable
                          when false
                            ['Discrete']
                          when true
                            ['Continuous']
                          end
  top_ten_medicare = %w(0013 0018 0028 0031 0032 0034 0043 0419 0421)
  top_ten_medicare.each { |m| measure_hash['tags'] += ['Top 10 Medicare eCQMs'] if measure.nqf_id == m }
  measure_tags += [measure_hash]
end
measure_tags.uniq!
File.open('lib/cedar/measure_tags.json', 'w') { |file| file.write(JSON.pretty_generate(measure_tags)) }
