module Api
  module Auth
    class SessionsController < ApplicationController
      
      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password]) && user.active?
          session[:user_id] = user.id
          render json: { message: 'Logged in successfully', user: user.slice(:id, :email, :username, :role, :active) }, status: :ok
        else
          render json: { error: 'Invalid email or password, or account inactive' }, status: :unauthorized
        end
      end

      def destroy
        session[:user_id] = nil
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      def me
        if session[:user_id]
          user = User.find_by(id: session[:user_id])
          if user
            render json: { user: user.slice(:id, :email, :username, :role, :active) }, status: :ok
          else
            render json: { user: nil }, status: :ok
          end
        else
          render json: { user: nil }, status: :ok
        end
      end
    end
  end
end
