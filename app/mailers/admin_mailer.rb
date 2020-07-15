class AdminMailer < ApplicationMailer
  def contact
    @body = params[:body]
    @email  =  params[:email]
    @name  =  params[:name]
    mail(to: 'fernando@data.org.uy', subject: params[:subject])
  end
end
