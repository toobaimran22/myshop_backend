class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ActionController::Cookies

  before_action :set_current_user

  def current_user
    @current_user
  end

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    render json: { error: 'You must be logged in' }, status: :unauthorized unless @current_user
  end

  def authenticate_admin!
    render json: { error: 'Admin access required' }, status: :forbidden unless @current_user&.admin?
  end
end
