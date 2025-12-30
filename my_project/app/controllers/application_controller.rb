class ApplicationController < ActionController::Base
  include ActionPolicy::Controller
  
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  allow_browser versions: :modern

  stale_when_importmap_changes

  helper_method :current_user

  protected
  
  def authorization_context
    {user: current_user}
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
