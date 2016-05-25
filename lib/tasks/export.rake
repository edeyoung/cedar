
# Export all validations and seeds with: `rake export:seeds_format`
namespace :export do
  desc 'Exporting all validations in a seeds.rb way.'
  useless = %w(created_at updated_at _id test_execution_ids)
  task seeds_format: :environment do
    Validation.all.each do |validation|
      puts "Validation.create(
        #{validation.serializable_hash.delete_if do |key|
          useless.include?(key)
        end.to_s.gsub(/[{}]/, '')}
      )"
    end
  end
end
