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
    fill_in('user_email', with: 'scudmore@gmail.com')
    fill_in('user_password', with: 'password')
    # fill_in('user_email', with: @one_user.email)
    # fill_in('user_password', with: @one_user.password)
    find(:css, '#user_remember_me').set(true)
    click_button 'Log in'
    expect(page).to have_css('.db-overview-results')
    expect(find(:css, '.alert').visible?).to be true
    sleep 1
    # expect(find(:css, '.db-center-results div > :first-child .db-overview-results h1 p')).to have_content('total tests')
    expect(page).to have_content('Welcome to Cedar!')
  end
end
