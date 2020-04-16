ActiveAdmin.register Program do
  permit_params :name, :responsable, :responsable_url, :more_info, :reception_conditions, :contact, :information, :benefits, :lifecycle, :receives, :receives_no, :logo
  config.create_another = true
  index do
    selectable_column
    id_column
    column :logo do |l|
      image_tag url_for(l.logo)
    end
    column :name
    column :responsable
    column :contact
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
      f.input :logo, as: :file
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
