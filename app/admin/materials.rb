ActiveAdmin.register Material do
  permit_params :name, :icon, :information,:icon, :video, :color

  index do
    selectable_column
    id_column
    column :name
    column :information
    column :icon do |l|
      image_tag url_for(l.icon) if l.icon.attached?
    end
    column :video
    column :predefined_search
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :information
      f.input :icon, as: :file
      f.input :video
    end
    f.actions
  end
end
