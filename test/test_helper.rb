ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  teardown :global_teardown

  def global_teardown
    DatabaseCleaner.strategy = :truncation, { only: %w(users test_executions documents) }
    DatabaseCleaner.clean
    FactoryGirl.reload
  end

  def json(response)
    JSON.parse(response.body)
  end
end
