# spec/support/request_helpers.rb
require 'spec_helper'

module RequestHelpers
  def create_logged_in_user
    @a_user = FactoryGirl.create(:user)
    login(@a_user)
    @a_user
  end

  def login(user)
    login_as user, scope: :user
  end
end
