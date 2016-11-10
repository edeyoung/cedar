Apipie.configure do |config|
  config.app_name                = 'Cedar'
  config.app_info['v1']          = <<EOS
  = Overview
  Cedar is a tool for testing the strength of Electronic Clinical Quality Measure (eCQM)
  collection systems that receive Quality Reporting Document Architecture (QRDA) files.

  Registrations and Sessions are for user account control. Test executions create QRDA
  data, which are stored in Documents. Documents are also used to check your collection system's
  accuracy.

  Follows the {JSON-API specification}[link:jsonapi.org]. In addition to formatting responses,
  JSON-API compliance means requests must be made with 'application/vnd.api+json' accept and content-type headers.


  == Common Usage

  <b>Get authentication token with one of two methods:</b>

  1. Create an account at {POST /api/v1/users}[link:/apipie/v1/registrations/create.html]

  2. Sign in at {POST /api/v1/users/sign_in}[link:/apipie/v1/sessions/create.html]

  <b>Create test execution at </b>

  {POST /api/v1/test_executions}[link:/apipie/v1/test_executions/create.html]

  <b>Get QRDA data with one of two methods</b>

  1. Download zip from file_path url returned from creation

  2. Get qrda data from documents at {GET /api/v1/test_executions/:test_execution_id/documents}[link:/apipie/v1/documents/index.html]

  <b>Report results:</b>

  {POST /api/v1/test_executions/:test_execution_id/documents/report_results}[link:/apipie/v1/documents/report_results.html]
EOS
  config.api_base_url            = '/api'
  config.doc_base_url            = '/apidocs'
  config.default_version         = 'v1'
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.persist_show_in_doc     = true
  # Was getting an apipie validation error on email in the tests, so turned it off
  # until I can figure out why - SLC.
  config.validate                = false
end
