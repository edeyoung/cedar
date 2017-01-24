require 'rails_helper'
require 'fileutils'
require 'nokogiri'

RSpec.describe API::V1::ValidationsController, type: 'controller' do
  include RSpec::Matchers

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.headers['Accept'] = 'application/vnd.api+json'
    @request.headers['Content-Type'] = 'application/vnd.api+json'
    setup_fixture_data
    user = create(:user)
    sign_in user
  end

  it 'should get index' do
    get :index
    assert_response :success
    data = JSON.parse(response.body)
    @validations = data['validations']
    expect(@validations.length).to be >= 10 # there are 16 currently
  end

  it 'should show validation' do
    @v = Validation.all.first
    get :show, params: { id: @v.id.to_s, qrda_type: '1' }
    assert_response :success

    data = JSON.parse(response.body)
    byebug
    @validations = data['data']['validations']
    expect(@validations).to_not be_nil
  end
end
