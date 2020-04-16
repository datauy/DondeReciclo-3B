ActiveAdmin.register ContainerType do
  permit_params :name, :icon

  index do
    selectable_column
    id_column
    column :name
    column :icon, as: :image
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :icon, as: :file
    end
    f.actions
  end
end
