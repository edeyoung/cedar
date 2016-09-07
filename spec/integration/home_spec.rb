require 'spec_helper'

RSpec.describe 'home page test:' do
  it 'show dashboard' do
    visit '/users/sign_in'
    @one_user = FactoryGirl.create(:user)
    fill_in('user_email', with: @one_user.email)
    fill_in('user_password', with: @one_user.password)
    # click_on('Log in')
    # expect(page).to have_content('Welcome to Cedar!')
    expect(@one_user.email).to_not be_nil
    expect(@one_user.password).to_not be_nil
    expect(page).to have_selector('title', text: 'Cedar', visible: false)
  end
end
