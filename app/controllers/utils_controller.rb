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
          subject: params[:subject],
          country: params[:country_id].present? ? params[:country_id] : 1
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
  # Report issues
  def report
    begin
      if params[:email] && params[:name]
        message = "#{params[:comment]}<br><br>-----------------<br>Admin:#{request.host}/admin/containers/#{params[:id]}/edit"
        if params[:id].include? ','
          message = "#{params[:comment]}<br><br>-----------------#{request.client}<br>Location:https://dondereciclo.uy/lugar/#{params[:id]}"
        end
        req_params = [
          ['name', params[:name]],
          ['from', params[:email]],
          ['message', message],
          ['subject', "DR: Reportan #{params[:subject]}"],
          ['actAsType', "customer"]
        ]
        if params[:photo].present? || params[:subject] == 'foto'
          #attachments['file-name.jpg'] = File.read('file-name.jpg').
          name = params[:ClientFilename]#.split('\\').last
          tmp_file = "#{Rails.root}/tmp/#{name}"
          File.open(tmp_file, 'wb') do |f|
            f.write  request.body.read
          end
          req_params.push(['attachments', File.open(tmp_file)])
        end
        # Create Ticket
        uri = URI('https://soporte.data.org.uy/api/v1/ticket')

        req = Net::HTTP.new(uri.host, uri.port)
        req.use_ssl = true
        req.verify_mode = OpenSSL::SSL::VERIFY_NONE

        res = Net::HTTP::Post.new(uri.path)
        res['Authorization'] = "Basic #{Rails.application.credentials.dig(:"#{Rails.env}", :uv_token)}"
        res.set_form(req_params, 'multipart/form-data')
        response = req.request(res)
        if response.kind_of? Net::HTTPSuccess
          render json: {
            error:0,
            message:"delivered sccessfully"
          }, status: :ok
        else
          render json: {
            error: 1,
            message: response.body
          }, status: 500
        end
      end
    rescue StandardError => e
      render json: {
        error: 1,
        message: e.to_s
      }, status: 500
    end
  end
end
