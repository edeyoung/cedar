require 'capybara/rails'
require 'rails_helper'
# require '../support/request_helper'
require 'headless'

RSpec.describe 'home page test:', type: :feature do
  # include Devise::TestHelpers
  include Warden::Test::Helpers
  let(:authed_user) { create_logged_in_user }

  def create_logged_in_user
    @a_user = FactoryGirl.create(:user)
    login(@a_user)
    @a_user
  end

  def login(user)
    login_as user, scope: :user
  end

  it 'sign up new user' do
    visit 'localhost:3000/users/sign_up'
    fill_in('user_email', with: authed_user.email)
    fill_in('user_password', with: authed_user.password)
    fill_in('user_password_confirmation', with: authed_user.password)
    click_button 'Sign up'
    expect(page).to have_css('.db-overview-results')
    expect(find(:css, '.alert').visible?).to be true
    sleep 1
    expect(page).to have_content('Welcome! You have signed up successfully.')
    visit '/test_executions/new'
    sleep 3
  end

  xit 'show dashboard with hardcoded user' do
    visit 'localhost:3000/users/sign_in'
    fill_in('user_email', with: 'scudmore@gmail.com')
    fill_in('user_password', with: 'password')
    click_button 'Log in'
    expect(page).to have_css('.db-overview-results')
    expect(find(:css, '.alert').visible?).to be true
    sleep 1
    expect(page).to have_content('Welcome to Cedar!')
  end
end
