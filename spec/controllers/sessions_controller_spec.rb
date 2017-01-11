require 'rails_helper'
require 'fileutils'
require 'nokogiri'

RSpec.describe API::V1::SessionsController, type: 'controller' do
  include RSpec::Matchers
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.headers['Accept'] = 'application/vnd.api+json'
    @request.headers['Content-Type'] = 'application/vnd.api+json'
    setup_fixture_data
    @user = create(:user)
  end

  it 'valid sign in' do
    post :create, email: @user.email, password: @user.password
    data = JSON.parse(response.body)
    expect( data["user"]["authentication_token"]).not_to be_empty
  end

  it 'invalid sign in' do
    post :create, email: @user.email, password: 'incorrect'
    data = JSON.parse(response.body)
    expect( data["success"]).to eq false
  end

  it 'sign out' do
    post :create, email: @user.email, password: @user.password
    data = JSON.parse(response.body)
    expect( data["user"]["authentication_token"]).not_to be_empty
    token = @user.authentication_token
    @request.headers['X-API-TOKEN'] = token
    delete :destroy
    expect(token).to_not eq User.all.first.authentication_token
  end
end
