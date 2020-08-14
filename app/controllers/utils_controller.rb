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
  def report
    begin
      mail_params = {
        name: params[:name],
        email: params[:email],
        body: params[:comment],
        subject: "DR: Reportan #{params[:subject]}"
      }
      if !params[:photo].empty?
        #attachments['file-name.jpg'] = File.read('file-name.jpg').
        name = params[:ClientFilename]#.split('\\').last
        tmp_file = "#{Rails.root}/tmp/#{name}"
        File.open(tmp_file, 'wb') do |f|
          f.write  request.body.read
        end
        mail_params[:file] = tmp_file
      end
      logger.info("\n\nVPI\n\n")
      AdminMailer.
        with( mail_params ).
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
