require 'rails_helper'
require 'fileutils'
require 'nokogiri'

RSpec.describe 'API Integration Tests: ', type: 'request' do

  before(:each) do
    create_logged_in_user
    setup_fixture_data
  end

  it 'show user\'s executions' do
    # TODO use urls instead of :index, etc here
    get :index
    expect(response).to have_http_status(:success)
    executions = JSON.parse(response.body)
    # executions = json(response)['data']
    assert executions.any?
  end

  it 'get test execution by id' do
    @te = create(:te1)
    post '/api/v1/users/sign_in', { email: @te.user.email, password: @te.user.password }, headers: @header
    get '/api/v1/test_executions', { id: @te.id }, headers: @header
    expect(response).to have_http_status(:success)
    result = JSON.parse(response.body)
    assert_equal @te.name, result['data']['attributes']['name']
  end

  it 'create test' do

    a_user = create_logged_in_user
    expect(a_user.authentication_token).not_to be_empty
    post '/api/v1/users/sign_in', { email: a_user.email, password: a_user.password }, headers: @header
    post '/api/v1/test_executions',
         data: {
           attributes: {
             name: 'first',
             reporting_period: '2016',
             qrda_type: '1',
             measures: {
               tags: ['Hospital'],
               include: ['40280381-4BE2-53B3-014B-E66BED0703D0', 'CMS107v4', 'CMS100v4'],
               exclude: %w(CMS9v4 CMS91v5)
             },
             validations: {
               tags: ['Schema'],
               include: %w(discharge_after_upload)
             }
           }
         }
    expect(response).to have_http_status(:success)
    data = JSON.parse(response.body)

    measures = data['data']['attributes']['measures']
    validations = data['data']['attributes']['validations']
    assert_includes measures, 'CMS107v4'
    assert_includes measures, 'CMS100v4' # This is from 40280381-4B9A-3825-014B-C2730E6F088C in the measures include

    refute_includes measures, 'CMS9v4'
    assert_includes validations, 'discharge_after_upload'
    refute_includes validations, 'numer_greater_than_denom'
  end

  it 'create test with all' do
    a_user = create_logged_in_user
    expect(a_user.authentication_token).not_to be_empty
    post '/api/v1/users/sign_in', { email: a_user.email, password: a_user.password }, headers: @header

    post '/api/v1/test_executions',
         data: {
           attributes: {
             name: 'all',
             reporting_period: '2015',
             qrda_type: '1',
             measures: { all: true },
             validations: { all: true }
           }
         }
    expect(response).to have_http_status(:success)
  end

  it 'create invalid test' do
    post :create,
         data: {
           attributes: {
             name: 'incompatible measure and validation',
             reporting_period: '2016',
             qrda_type: '3',
             measures: { include: ['CMS55v4'] },
             validations: { include: ['numer_greater_than_denom'] }
           }
         }
    assert_response 400
  end

  it 'delete test' do
    @te = create(:te1)
    delete '/api/v1/test_executions', id: @te.id
    expect(response).to have_http_status(:success)
    assert_empty TestExecution.where(id: @te.id).documents
  end
end
