require 'capybara/rails'
require 'rails_helper'
require 'headless'

RSpec.describe 'home page test:', type: :feature do
  # headless = Headless.new
  # headless.start
  it 'show dashboard' do
    visit 'http://localhost:3000/users/sign_in'
    expect(page).to have_selector('title', text: 'Cedar', visible: false)
    @one_user = FactoryGirl.create(:user)
    expect(@one_user.email).to_not be_nil
    expect(@one_user.password).to_not be_nil
    fill_in('user_email', with: @one_user.email)
    fill_in('user_password', with: @one_user.password)
    sleep 3
    # expect(page).to have_content('Please sign in or create a new account.')
    find('input#LogIn').click
    sleep 1
    # expect(page).to have_content('Welcome to Cedar!')
    # expect(page).should have_content('Welcome to Cedar!')
  end
end
