class AdminMailer < ApplicationMailer
  def contact
    @body = params[:body]
    @email  =  params[:email]
    @name  =  params[:name]
    mail(to: 'soporte@data.org.uy', subject: params[:subject], from: params[:email])
  end
end
