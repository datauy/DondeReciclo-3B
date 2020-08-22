class ApplicationController < ActionController::Base
  respond_to :json, :html
  protect_from_forgery with: :null_session

  protected
  # Devise methods
  # Authentication key(:username) and password field will be added automatically by devise.
  def configure_permitted_parameters
    added_attrs = [:email, :name, :sex, :state, :neighborhood, :age]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
