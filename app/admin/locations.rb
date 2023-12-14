ActiveAdmin.register Location do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :geometry, :loc_type, :code, :parent_location, :country_id, :parent_location_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  menu if: proc{ current_admin_user.is_admin? }
  before_action :authenticate
  #
  controller do
    def authenticate
      if !current_admin_user.is_admin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
  end
  #
  index do
    selectable_column
    id_column
    column :name
    column :geometry do |l|
      l.geometry.present? ? true : false
    end
    actions
  end
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :loc_type
      f.input :code
      f.input :parent_location
      f.input :country_id
      f.input :geometry, :as => :text
    end
    f.actions
  end
end
