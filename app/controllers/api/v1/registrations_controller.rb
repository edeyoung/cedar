module API
  module V1
    class RegistrationsController < Devise::RegistrationsController
      prepend_before_action :allow_params_authentication!, only: :create

      respond_to :json

      def create
        user = User.new(params.permit(:email, :password))
        if user.save
          render json: { user: { email: user.email, authentication_token: user.authentication_token } }, status: 201
          return
        else
          warden.custom_failure!
          render json: user.errors, status: 422
        end
      end
    end
  end
end
