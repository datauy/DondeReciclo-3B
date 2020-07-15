class UtilsController < ApplicationController
  #
  def contact_email
    AdminMailer.
      with(
        name: params[:name],
        email: params[:email],
        body: params[:body],
        subject: params[:subject]
      ).
      contact.
      deliver
  end
end
