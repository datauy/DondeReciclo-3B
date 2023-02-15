class UserApiController < ApplicationController
  before_action :doorkeeper_authorize!
  respond_to    :json
  # GET /me.json
  def me
    render json: current_resource_owner
  end

  def delete
    user = current_resource_owner
    anonUser = User.find_by({email: "devops@data.org.uy"})
    user.reports.update_all({user_id: anonUser.id})
    ActiveRecord::Base.connection.execute("delete from oauth_access_tokens where resource_owner_id = #{doorkeeper_token.resource_owner_id}")
    user.delete()
    render json: {
      error:0,
      message:"User deleted"
    }, status: :ok
  end

  def update
    user = current_resource_owner
    new_data = params[:user_api].permit(:name, :email, :sex, :state, :neighborhood, :age, :country_id)
    user.update!(new_data)
    render json: user
  end

  def report
    begin
      user = current_resource_owner
      req_params = [
        ['name', user.name],
        ['from', user.email],
        ['message', "#{params[:comment]}<br><br>-----------------<br>Admin:#{request.host}/admin/containers/#{params[:id]}/edit"],
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
    rescue StandardError => e
      render json: {
        error: 1,
        message: e.to_s
      }, status: 500
    end
  end
  # Store Collect Report Send collect
  def collect
    begin
      user = current_resource_owner
      address = "#{params[:address]}, #{params[:addressDetail]}"
      suprog = SubProgram.find(params[:id])
      #wastes_materials = {
      #  wastes: [],
      #  materials: []
      #}
      #params[:wasteType].each do |waste|
      #  waste_arr = waste.split(',')
      #  wType = waste_arr[1]
      #  wastes_materials[:"#{wType}"] << waste_arr[0].to_i
        #logger.info { "\n#{wType}\n #{wastes_materials[:"#{wType}"].inspect}\n\n" }
      #end
      #Create report for stats
      report_data = {
        coords: "POINT(#{params[:latlng]})",
        sub_program: suprog,
        user_id: user.id,
        address: address,
        weight: params[:weight],
        comment: params[:comment],
        donation: params[:donation],
        country_id: 2,
        #waste_ids: wastes_materials[:wastes],
        #material_ids: wastes_materials[:materials],
      }
      #logger.info report_data.inspect
      rep = Report.create(report_data)
      rep.save
      #Send email
      mail_params = {
        latlng: params[:latlng],
        name: params[:name],
        email: params[:email],
        phone: params[:phone],
        comment: params[:comment],
        subject: "DR - Recolección #{rep.id} - #{suprog.name}",
        weight: params[:weight],
        neighborhood: params[:neighborhood],
        address: address,
        subprogram: suprog.name,
        city: suprog.city
      }
      AdminMailer.
        with( mail_params ).
        collect.
        deliver
      #
      #Return result
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
