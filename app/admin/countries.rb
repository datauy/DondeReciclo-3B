ActiveAdmin.register Country do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :contact, :code, :locale, :lat, :lon
  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  menu if: proc{ current_admin_user.is_superadmin? }
  before_action :authenticate
  #
  controller do
    def authenticate
      if !current_admin_user.is_superadmin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
  end
  index do
    selectable_column
    id_column
    column :name
    column :contact
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :code
      f.input :locale
      f.input :contact
      f.input :lat
      f.input :lon
    end
    f.actions
  end

end
