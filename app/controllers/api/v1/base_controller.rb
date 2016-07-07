module API
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_user_from_token!
      before_action :destroy_session
      before_action :authenticate_user!

      # Apipie
      def_param_group :headers do
        param :street, String
        param :number, Integer
        param :zip, String
      end

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
    end
  end
end
