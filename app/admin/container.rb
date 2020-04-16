ActiveAdmin.register Container do
  permit_params :sub_program_id, :external_id, :lat, :long, :site, :address, :location, :state, :site_type, :public_site, :container_type_id
  config.create_another = true
  index do
    selectable_column
    id_column
    column :sub_program_id
    column :external_id
    column :lat
    column :long
    column :site
    column :state
    column :public_site
    column :container_type_id
    column :created_at
    actions
  end

  filter :sub_program_id, as: :select, collection: SubProgram.all.map{|s| [s.name, s.id]}
  filter :state
  filter :public_site
  filter :container_type_id, as: :select, collection: ContainerType.all.map{|s| [s.name, s.id]}
  filter :created_at

  form do |f|
    f.inputs do
      f.input :sub_program_id, :label => 'Subprograma', :as => :select, :collection => SubProgram.all.map{|s| [s.name, s.id]}
      f.input :external_id
      f.input :lat
      f.input :long
      f.input :site
      f.input :address
      f.input :location
      f.input :state
      f.input :site_type
      f.input :public_site
      f.input :container_type_id, :label => 'Tipo de contenedor', :as => :select, :collection => ContainerType.all.map{|s| [s.name, s.id]}
    end
    f.actions
  end
=begin
  controller do
    def scoped_collection
      if current_user.subprogram.nil?
        resource_class
      else
        resource_class.where(collage: current_user.school_type)
      end
    end
  end
=end
end
