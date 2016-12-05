require 'rails_helper'
require 'fileutils'
require 'nokogiri'

RSpec.describe 'Validations Controller Tests: ', type: 'request' do
  include Warden::Test::Helpers
  Warden.test_mode!
  before(:each) do
    create_logged_in_user
    setup_fixture_data
  end

  it 'show all' do
    get '/api/v1/validations', qrda_type: 3, measure_type: 'all', tag: 'Calculation'
    expect(response).to have_http_status(:success)
    executions = JSON.parse(response.body)
    assert executions.any?
  end

  it 'get validation' do
    @v = Validation.all.first
    get '/api/v1/validations/' + @v.code
    expect(response).to have_http_status(:success)
    result = JSON.parse(response.body)
    assert_equal @v.code, result['code']
  end
end
