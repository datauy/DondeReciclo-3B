ActiveAdmin.register ContainerType do
  permit_params :name, :icon
  menu if: proc{ current_admin_user.is_superadmin? }
  before_action :authenticate
  #
  index do
    selectable_column
    id_column
    column :name
    column :icon do |l|
      image_tag url_for(l.icon) if l.icon.attached?
    end
  end
  #
  filter :name
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :icon, as: :file
    end
    f.actions
  end
  #
  controller do
    def authenticate
      if !current_admin_user.is_superadmin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
  end
end
