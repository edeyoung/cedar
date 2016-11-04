require 'capybara/rails'
require 'rails_helper'
# require '../support/request_helper'
require 'headless'

RSpec.describe 'home page test:', type: :feature do
  # include Devise::TestHelpers
  include Warden::Test::Helpers
  # Warden.test_mode!
  let(:authed_user) { create_logged_in_user }

  def create_logged_in_user
    @a_user = FactoryGirl.create(:user)
    login(@a_user)
    @a_user
  end

  def login(user)
    login_as user, scope: :user
  end

  def log_user_out
    find('a', text: 'Account').click
    find('a', text: 'Sign Out').click
  end

  it 'sign up new user' do
    @new_user = authed_user
    visit 'localhost:3000/users/sign_up'
    sleep 1
    fill_in('user_email', with: @new_user.email)
    fill_in('user_password', with: @new_user.password)
    fill_in('user_password_confirmation', with: @new_user.password)
    click_button 'Sign up'
    expect(page).to have_css('.db-overview-results')
    expect(find(:css, '.alert').visible?).to be true
    expect(page).to have_content('TOTAL TESTS')
    expect(page).to have_content('Welcome! You have signed up successfully.')
    sleep 1
  end

  it 'sign in user' do
    @new_user = authed_user
    # puts @new_user.email + ' sign in.....'
    visit 'localhost:3000/users/sign_up'
    fill_in('user_email', with: @new_user.email)
    fill_in('user_password', with: @new_user.password)
    fill_in('user_password_confirmation', with: @new_user.password)
    click_button 'Sign up'
    expect(page).to have_content('Welcome! You have signed up successfully.')
    log_user_out
    fill_in('user_email', with: @new_user.email)
    fill_in('user_password', with: @new_user.password)
    click_button 'Log in'
    expect(page).to have_content('Welcome to Cedar!')
    expect(page).to have_content('TOTAL TESTS')
    visit '/test_executions/new'
    expect(page).to have_content('QRDA Type')
    log_user_out
    sleep 3
  end
end
