require 'rails_helper'
require 'fileutils'
require 'nokogiri'

module API
  module V1
    RSpec.describe 'Sessions Controller Tests: ', type: 'request' do
      before(:each) do
        @user = create(:user)
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
      end

      it 'valid sign in' do
        post :create, email: @user.email, password: @user.password

        expect(response).to have_http_status(:success)

        user = json(response)['user']
        assert_not_nil user['authentication_token']
      end

      it 'invalid sign in' do
        post :create, email: Faker::Internet.email, password: 'incorrect'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'sign out' do
        token = @user.authentication_token
        @request.headers['X-API-TOKEN'] = token
        delete :destroy, {}

        assert_not_equal token, User.all.first.authentication_token
      end
    end
  end
end
