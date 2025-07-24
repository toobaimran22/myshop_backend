module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!, except: [:create]
      before_action :set_user, only: [:show, :update, :activate, :deactivate, :assign_admin, :remove_admin]
      before_action :authenticate_admin!, only: [:activate, :deactivate, :assign_admin, :remove_admin]

      def index
        users = User.all
        render json: users.select(:id, :email, :username, :role, :active)
      end

      def show
        authorize @user
        render json: @user.slice(:id, :email, :username, :role, :active)
      end

      def update
        authorize @user
        if @user.update(user_params)
          render json: @user.slice(:id, :email, :username, :role, :active)
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def activate
        authorize @user, :activate?
        @user.update(active: true)
        render json: @user.slice(:id, :email, :username, :role, :active)
      end

      def deactivate
        authorize @user, :deactivate?
        @user.update(active: false)
        render json: @user.slice(:id, :email, :username, :role, :active)
      end

      def assign_admin
        authorize @user, :assign_admin?
        @user.update(role: :admin)
        render json: @user.slice(:id, :email, :username, :role, :active)
      end

      def remove_admin
        authorize @user, :assign_admin?
        @user.update(role: :user)
        render json: @user.slice(:id, :email, :username, :role, :active)
      end

      def create
        user = User.new(user_params)
        user.role ||= "user"
        user.active = true if user.active.nil?
        if user.save
          render json: user.slice(:id, :email, :username, :role, :active), status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :username, :password, :password_confirmation)
      end
    end
  end
end 