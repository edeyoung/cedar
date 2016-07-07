Apipie.configure do |config|
  config.app_name                = 'Cedar'
  config.app_info['v1']          = <<EOS
  = Overview
  Cedar is a tool for testing the strength of Electronic Clinical Quality Measure (eCQM)
  collection systems that receive Quality Reporting Document Architecture (QRDA) files.

  Registrations and Sessions are for user account control. Test executions create QRDA
  data, which are stored in Documents. Documents are also used to check your collection system's
  accuracy.

  == Common Usage
  <b>Create an account:</b>

  POST /api/v1/users

  <b>Get authentication token:</b>

  POST /api/v1/users/sign_in

  <b>Create test execution:</b>

  POST /api/v1/test_executions

  <i>Download qrda files and test them on your collection system</i>

  <b>Report results:</b>

  POST /api/v1/test_executions/:id/report_results
EOS
  config.api_base_url            = '/api'
  config.doc_base_url            = '/apipie'
  config.default_version         = 'v1'
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
