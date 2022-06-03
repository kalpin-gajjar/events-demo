class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_out_path_for(resource)
    root_path
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :expires_at, :access_token, :refresh_token) }

    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :expires_at, :access_token, :refresh_token, :password, :current_password) }
  end
end
