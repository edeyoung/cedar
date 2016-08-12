module API
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_user_from_token!
      before_action :destroy_session
      before_action :authenticate_user!

      # Authentication
      def destroy_session
        request.session_options[:skip] = true
      end

      def authenticate_user_from_token!
        user_email = request.headers['X-API-EMAIL'].presence
        user_auth_token = request.headers['X-API-TOKEN'].presence
        user = user_email && User.find_by(email: user_email)

        # Devise.secure_compare to compare the token, mitigating timing attacks
        if user && Devise.secure_compare(user.authentication_token, user_auth_token)
          sign_in(user, store: false)
        end
      end

      # Make APIPIE send a comprehensible error message when validating parameters
      rescue_from Apipie::ParamError do |e|
        render json: { errors: [{ title: e.message }] }, status: 400
      end
    end
  end
end
