class AdminMailer < ApplicationMailer
  def contact
    if !params[:file].empty?
      name = params[:file].split('/').last
      attachments[name] = File.read(params[:file])
      logger.info("\n FILE: #{name} \n")
    end
    @body = params[:body]
    @email  =  params[:email]
    @name  =  params[:name]
    mail(to: 'soporte@data.org.uy', subject: params[:subject], from: params[:email])
  end
end
