require 'rails_helper'
require 'fileutils'
require 'nokogiri'

module API
  module V1
    RSpec.describe 'Measures Controller Tests: ', type: 'request' do
      include RSpec::Matchers
      # include Devise::Test::ControllerHelpers

      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @request.headers['Accept'] = 'application/vnd.api+json'
        @request.headers['Content-Type'] = 'application/vnd.api+json'
        sign_in create(:user)
      end

      it 'show all' do
        get :index, reporting_period: 2015, tags: 'Continuous'
        expect(response).to have_http_status(:success)
        executions = json(response)['data']
        assert executions.any?
      end

      it 'get measure' do
        @m = Measure.all.first
        get :show, id: @m.cms_id
        expect(response).to have_http_status(:success)
        assert_equal @m.cms_id, json(response)['data']['id']
      end
    end
  end
end
