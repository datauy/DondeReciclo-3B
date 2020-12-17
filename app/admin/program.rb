ActiveAdmin.register Program do
  permit_params :name, :shortname, :responsable, :responsable_url, :more_info, :reception_conditions, :contact, :information, :benefits, :lifecycle, :receives, :receives_no, :logo, :icon, :country_id, material_ids: [], waste_ids: [], location_ids: []
  config.create_another = true
  index do
    selectable_column
    id_column
    column :name
    column :responsable
    column :contact
    column :logo do |l|
      image_tag url_for(l.logo) if l.logo.attached?
    end
    column :icon do |l|
      image_tag url_for(l.icon) if l.icon.attached?
    end
    column :created_at
    actions
  end

  filter :name
  filter :responsable
  filter :contact
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :shortname
      f.input :logo, as: :file
      f.input :icon, as: :file
      f.input :responsable
      f.input :responsable_url
      f.input :more_info
      f.input :reception_conditions
      f.input :contact
      f.input :information
      f.input :benefits
      f.input :lifecycle
      f.input :receives
      f.input :receives_no
      f.inputs "Materiales" do
        f.input :materials, as: :check_boxes
        #f.object.materials.build
        #f.has_many :materials, new_record: 'Agregar Material' do |m|
        #  m.input :name
        #  m.input :information
        #  m.input :video
        #  m.input :color
        #end
      end
      f.inputs "Wastes" do
        f.input :wastes, as: :check_boxes
      end
      f.inputs "Country" do
        f.input :country_id, :as => :select, :collection => Country.all.map{|s| [s.name, s.id]}
      end
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
