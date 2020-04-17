ActiveAdmin.register Material do
  permit_params :name, :icon

  index do
    selectable_column
    id_column
    column :name
    column :information
    column :video
    column :color
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :information
      f.input :video
      f.input :color
    end
    f.actions
  end
end
