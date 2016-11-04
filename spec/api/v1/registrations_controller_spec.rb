require 'rails_helper'
require 'fileutils'
require 'nokogiri'

module API
  module V1
    RSpec.describe 'Reginstrations Controller Tests: ', type: 'request' do
      include RSpec::Matchers
      # include Devise::Test::ControllerHelpers

      it 'create account' do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        post :create, attributes_for(:user)

        expect(response).to have_http_status(:success)

        user = json(response)['user']
        assert_not_nil user['authentication_token']
      end
    end
  end
end
