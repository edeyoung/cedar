require 'rails_helper'
require 'fileutils'
require 'nokogiri'

RSpec.describe API::V1::ValidationsController, type: 'controller' do
  include RSpec::Matchers

  before(:each) do
    setup_fixture_data
    user = create(:user)
    sign_in user
  end

  it 'should get index' do
    get :index
    assert_response :success
    data = JSON.parse(response.body)
    @validations = data['data'][0]['type']
    expect(@validations).to_not be_nil
  end

  it 'should show validation' do
    @v = Validation.all.first
    get :show, id: @v.id.to_s
    assert_response :success

    data = JSON.parse(response.body)
  byebug
    @validations = data['data']['validations']
    expect(@validations).to_not be_nil
  end
end
