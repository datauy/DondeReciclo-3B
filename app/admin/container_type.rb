ActiveAdmin.register ContainerType do
  permit_params :name, :icon

  index do
    selectable_column
    id_column
    column :name
    column :icon do |l|
      image_tag url_for(l.icon) if l.icon.attached?
    end
  end

  filter :name

  form do |f|
    f.inputs do
      f.input :name
      f.input :icon, as: :file
    end
    f.actions
  end
end
