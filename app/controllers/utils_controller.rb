class UtilsController < ApplicationController
  protect_from_forgery with: :null_session
  #
  def contact_email
    begin
      AdminMailer.
        with(
          name: params[:name],
          email: params[:email],
          body: params[:body],
          subject: params[:subject]
        ).
        contact.
        deliver
      render json: {
        error:0,
        message:"delivered sccessfully"
      }, status: :ok
    rescue StandardError => e
      render json: {
        error: 1,
        message: e.to_s
      }, status: 500
    end
  end
  def forgot_email(user)
    begin
      AdminMailer.
        with(
          name: user.name,
          email: user.email,
          token: user.reset_password_token
        ).
        forgot.
        deliver
      render json: {
        error:0,
        message:"delivered sccessfully"
      }, status: :ok
    rescue StandardError => e
      render json: {
        error: 1,
        message: e.to_s
      }, status: 500
    end
  end
  def forgot
    if params[:email].blank? # check if email is present
      return render json: {error: 'El email no está presente'}
    end
    user = User.find_by(email: params[:email]) # if present find user by email
    if user.present?
      user.generate_password_token! #generate pass token
      forgot_email(user);
    else
      render json: {error: 'No existe el email'}, status: :not_found
    end
  end

  def reset
    token = params[:token].to_s
    user = User.find_by(reset_password_token: token)
    if user.present? && user.password_token_valid? && params[:password].present?
      if user.reset_password!(params[:password])
        render json: {status: 'ok'}, status: :ok
      else
        render json: {error: user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {error:  'El link no es válido o ha expirado.'}, status: :not_found
    end
  end
end
