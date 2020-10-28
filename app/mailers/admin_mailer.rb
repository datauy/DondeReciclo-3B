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
    country_id = params[:country] ? params[:country] : 1
    contact = Country.
      find(country_id).
      pluck('contact')
    logger.info(country.inspect)
    mail(to: contact, subject: params[:subject], from: params[:email])
  end
  def collect
    @email = params[:email]
    @name = params[:name]
    @address = params[:address]
    @body = params[:body]
    @weight = params[:weight]
    @latlng = params[:latlng]
    Rails.logger.info("\nENviando emial\n")
    mail(
      to: 'dondereciclo@data.org.uy',
      subject: params[:subject],
      from: params[:email],
    #  username: 'dondereciclo@data.org.uy',
    #  password: 'Ost3Ras'
    )
  end
  def forgot
    @name  =  params[:name]
    @token = params[:token]
    mail(to: params[:email], subject: 'Nueva contraseña en ¿Dónde Reciclo?')
  end
end
