class UserApiController < ApplicationController
  before_action :doorkeeper_authorize!
  respond_to    :json
  # GET /me.json
  def me
    render json: current_resource_owner
  end

  def report
    begin
      user = current_resource_owner
      mail_params = {
        name: user.name,
        email: user.email,
        body: params[:comment],
        subject: "DR: Reportan #{params[:subject]}"
      }
      if params[:photo].present? || params[:subject] == 'foto'
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

  private
  # Find the user that owns the access token
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
