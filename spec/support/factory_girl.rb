RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = 'mongoid'
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean_with(:truncation)
    end
  end
  # I'm not sure if we want to clean before each test... probably not?
  config.before(:each) do
    DatabaseCleaner.clean
  end
end
