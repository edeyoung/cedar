source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.5.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running
# in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Cedar Additions
# Mongo for our database
gem 'mongoid', '~> 5.0.0'
# Devise for user configuration
gem 'devise'
# Protected attributes to prevent mass assignment of things like admin settings
# gem 'protected_attributes'
# Wicked for creating the wizard
gem 'wicked'
# State Machine for tracking test statuses
gem 'aasm'
# We want non-digest versions of our assets for any font
gem 'non-stupid-digest-assets'
# Add some bootstrap
gem 'bootstrap-sass'
# For the progress indicator
gem 'bootstrap-slider-rails'
# Randomized names and companies for the QRDA files
gem 'faker'
# health-data-standards to create QRDA documents
gem 'health-data-standards', git: 'https://github.com/projectcypress/health-data-standards.git', branch: 'bump_mongoid'
# Quality Measure Engine to create CQMs
gem 'quality-measure-engine', git: 'https://github.com/projectcypress/quality-measure-engine.git', branch: 'bump_mongoid'
# For zipping QRDA documents once they are created
gem 'rubyzip'
# Prettier replacements for javascript alerts
gem 'sweet-alert-confirm'
# Date range picker and momentjs dependency
gem 'momentjs-rails'
gem 'bootstrap-daterangepicker-rails'
# Validation coverage pagination
gem 'kaminari'

group :development, :test do
  # Rubocop for syntax checking and code cleanliness
  gem 'rubocop'
  # Call 'byebug' anywhere in the code to stop execution and get a debug console
  gem 'byebug'
  # Capybara and selenium for automated testing
  gem 'capybara'
  gem 'capybara-accessible'
  gem 'axe-matchers'
  gem 'selenium-webdriver', '2.48.0'
  # Brakeman and bundle-audit for automated testing of security vulnerabilities
  gem 'brakeman', require: false
  gem 'bundler-audit'
end

group :production do
  gem 'unicorn-rails'
end
