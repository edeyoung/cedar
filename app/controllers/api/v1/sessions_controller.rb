# From http://soryy.com/blog/2014/apis-with-devise/
module API
  module V1
    class SessionsController < Devise::SessionsController
      resource_description do
        short 'Get authentication tokens'
        formats ['json']
      end
      skip_before_action :authenticate_user!, only: [:create, :new]
      skip_before_action :verify_signed_out_user
      respond_to :json_api

      api! 'get auth token'
      param :email, String, required: true
      param :password, String, required: true
      def create
        resource = resource_from_credentials
        return invalid_login_attempt unless resource

        if resource.valid_password?(params[:password])
          render json: { user: { email: resource.email, authentication_token: resource.authentication_token } }, success: true, status: :created
        else
          invalid_login_attempt
        end
      end

      api! 'regenerate auth token'
      header 'X-API-TOKEN', 'user\'s current authentication token', required: true
      def destroy
        user = User.find_by(authentication_token: request.headers['X-API-TOKEN'])
        if user
          user.reset_authentication_token!
          user.save
          render json: { message: 'Token reset.' }, success: true, status: 200
        else
          render json: { message: 'Invalid token.' }, status: 404
        end
      end

      protected

      def invalid_login_attempt
        warden.custom_failure!
        render json: { success: false, message: 'Error with your login or password' }, status: 401
      end

      def resource_from_credentials
        data = { email: params[:email] }
        res = resource_class.find_for_database_authentication(data)
        res if res && res.valid_password?(params[:password])
      end
    end
  end
end
