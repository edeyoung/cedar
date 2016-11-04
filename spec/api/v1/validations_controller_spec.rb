require 'rails_helper'
require 'fileutils'
require 'nokogiri'

RSpec.describe 'Validations Controller Tests: ', type: 'request' do
  # include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.headers['Accept'] = 'application/vnd.api+json'
    @request.headers['Content-Type'] = 'application/vnd.api+json'
    sign_in create(:user)
    user = double('user')
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  it 'show all' do
    allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, scope: 'user')
    get :index, qrda_type: 3, measure_type: 'all', tag: 'Calculation'
    expect(response).to have_http_status(:success)
    executions = json(response)['data']
    assert executions.any?
  end

  it 'get validation' do
    @v = Validation.all.first
    get :show, id: @v.code
    expect(response).to have_http_status(:success)
    assert_equal @v.code, json(response)['data']['id']
  end
end
