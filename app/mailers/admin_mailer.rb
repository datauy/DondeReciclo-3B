class AdminMailer < ApplicationMailer
  def contact
    if params[:file].present?
      name = params[:file].split('/').last
      attachments[name] = File.read(params[:file])
    end
    @body = params[:body]
    @email  =  params[:email]
    @name  =  params[:name]
    mail(to: 'soporte@data.org.uy', subject: params[:subject], from: params[:email])
  end
  def forgot
    @name  =  params[:name]
    @token = params[:token]
    mail(to: params[:email], subject: 'Nueva contraseña en ¿Dónde Reciclo?')
  end
end
