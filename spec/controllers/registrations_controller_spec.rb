require 'rails_helper'
require 'fileutils'
require 'nokogiri'

RSpec.describe API::V1::RegistrationsController, type: 'controller' do
  include RSpec::Matchers

  it 'create account' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    post :create, attributes_for(:user)
    expect(response).to have_http_status(:success)
    data = JSON.parse(response.body)
    expect(data['user']['authentication_token']).to_not be_nil
  end
end
