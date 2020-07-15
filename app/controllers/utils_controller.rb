class UtilsController < ApplicationController
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
end
