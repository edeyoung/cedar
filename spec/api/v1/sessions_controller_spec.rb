require 'rails_helper'
require 'fileutils'
require 'nokogiri'

  RSpec.describe 'Sessions Controller Tests: ', type: 'request' do
    include Warden::Test::Helpers
    Warden.test_mode!
    before(:each) do
      setup_fixture_data
      @user = create(:user)
      byebug
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers['Accept'] = 'application/vnd.api+json'
      @request.headers['Content-Type'] = 'application/vnd.api+json'
    end

    it 'valid sign in' do
      post '/api/v1/sign_in', { email: @user.email, password: @user.password }

      expect(response).to have_http_status(:success)

      user = json(response)['user']
      assert_not_nil user['authentication_token']
    end

    it 'invalid sign in' do
      post '/api/v1/sign_in', { email: Faker::Internet.email, password: 'incorrect' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'sign out' do
      token = @user.authentication_token
      @request.headers['X-API-TOKEN'] = token
      delete :destroy, {}

      assert_not_equal token, User.all.first.authentication_token
    end
  end
