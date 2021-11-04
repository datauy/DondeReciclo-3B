ActiveAdmin.register Container do
  permit_params :sub_program_id, :external_id, :latitude, :longitude, :site, :address, :location, :state, :information, :site_type, :public_site, :hidden, :container_type_id, :custom_icon, photos:[], schedule_ids:[], schedules_attributes:[:id, :weekday, :start, :end, :desc, :closed]
  config.create_another = true
  index do
    selectable_column
    id_column
    column :sub_program do |s|
      s.sub_program.name
    end
    column "Ver contenedor" do |s|
      link_to "Ir al sitio", "https://dondereciclo.uy/intro/mapa/contenedor/#{s.id}", target: "_blank"
    end
    column :external_id
    column :latitude
    column :longitude
    column :site
    column :state
    column :information
    column :public_site
    column :hidden
    column :container_type do |c|
      c.container_type.name
    end
    column :created_at
    column :photos do |l|
      if l.photos.attached?
        l.photos.map{ |photo| image_tag url_for(photo) }
      end
    end
    actions
  end

  show do
    attributes_table do
      row :sub_program do |s|
        #auto_link(s.sub_program)
        link_to s.sub_program.name, auto_url_for(s.sub_program), target: "_blank"
      end
      row "Ver contenedor" do |s|
        link_to "Ir al sitio", "https://dondereciclo.uy/intro/container/#{s.id}", target: "_blank"
      end
      row :external_id
      row :latitude
      row :longitude
      row :site
      row :state
      row :information
      row :public_site
      row :hidden
      row :container_type do |c|
        c.container_type.name
      end
      row :created_at
      row :photos do |l|
        if l.photos.attached?
          l.photos.map{ |photo| image_tag url_for(photo) }
        end
      end
    end
  end

  filter :id
  filter :sub_program_id, as: :select, collection: SubProgram.all.map{|s| [s.name, s.id]}
  filter :country_id, as: :select, collection: Country.all.map{|s| [s.name, s.id]}
  filter :state
  filter :public_site
  filter :container_type_id, as: :select, collection: ContainerType.all.map{|s| [s.name, s.id]}
  filter :created_at

  form :html => { :multipart => true } do |f|
    f.inputs do
      f.input :sub_program_id, :label => 'Subprograma', :as => :searchable_select, :collection => SubProgram.all.map{|s| [s.name, s.id]}
      f.input :external_id
      f.input :latitude
      f.input :longitude
      f.input :state
      f.input :location
      f.input :address
      f.input :site
      f.input :site_type
      f.input :public_site
      f.input :information
      f.input :hidden
      f.input :container_type_id, :label => 'Tipo de contenedor', :as => :select, :collection => ContainerType.all.map{|s| [s.name, s.id]}
      f.input :photos, as: :file, input_html: { multiple: true }
      f.input :custom_icon, as: :file
      if f.object.custom_icon.attached?
        span image_tag(f.object.custom_icon)
          a "Borrar", src: delete_file_admin_container_path(f.object.custom_icon.id), "data-method": :delete, "data-confirm": "Confirme que desea eliminarla"
      end
      if f.object.photos.attached?
        f.object.photos.each do |image|
          span image_tag(image)
          a "Borrar", src: delete_file_admin_container_path(image.id), "data-method": :delete, "data-confirm": "Confirme que desea eliminarla"
        end
      end
      f.input :schedules, as: :select, collection: Schedule.all.map{|s| [s.desc, s.id]}
      f.has_many :schedules do |sched|
        sched.inputs
      end
    end
    f.actions
  end
  #
  controller do
    def scoped_collection
      if current_admin_user.is_superadmin?
        resource_class
      else
        resource_class.includes(sub_program:[:program]).where("programs.country_id": current_admin_user.country_id)
      end
    end
  end
  #
  member_action :delete_file, method: :delete do
    @pic = ActiveStorage::Attachment.find(params[:id])
    @pic.purge_later
    redirect_back(fallback_location: edit_admin_container_path)
  end
  #
  batch_action :hide, confirm: "Seguro que querés ocultarlos?" do |ids|
    Container.where(:id => ids).update_all( :hidden => true )
    redirect_to collection_path, alert: "Se ocultaron los contenedores seleccionados"
  end
  #
  batch_action :add_schedule, form: -> {
    { schedule: Schedule.all.map{|sched| [sched.formated_str, sched.id]} }
  } do |ids, inputs|
    # inputs is a hash of all the form fields you requested
    redirect_to collection_path, notice: [ids, inputs].to_s
  end
end
