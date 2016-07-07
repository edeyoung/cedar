# All Controllers inherit from ApplicationController
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }
  layout :layout_by_resource

  protected

  def layout_by_resource
    if devise_controller?
      'devise'
    else
      'application'
    end
  end
end
