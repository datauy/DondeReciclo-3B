class AdminMailer < ApplicationMailer
  def contact
    if params[:file].present?
      name = params[:file].split('/').last
      attachments[name] = File.read(params[:file])
    end
    @body = params[:body]
    @email = params[:email]
    @name = params[:name]
    if (params[:container_url])
      @container_url  =  params[:container_url]
    end
    country_id = params[:country]
    contact = Country.
      find(country_id).
      contact
    mail(to: contact, subject: params[:subject], from: params[:email])
  end
  def collect
    @email = params[:email]
    @phone = params[:phone]
    @name = params[:name]
    @neighborhood = params[:neighborhood]
    @address = params[:address]
    @comment = params[:comment]
    @weight = params[:weight]
    @latlng = params[:latlng]
    mail(
      to: 'soporte@dondereciclo.co',
      subject: params[:subject],
    #  from: params[:email],
    #  username: 'dondereciclo@data.org.uy',
    )
  end
  def forgot
    @name  =  params[:name]
    @token = params[:token]
    mail(to: params[:email], subject: 'Nueva contraseña en ¿Dónde Reciclo?')
  end
end
