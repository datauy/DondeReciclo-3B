ActiveAdmin.register PredefinedSearch do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :country_id, :wastes_id, :materials_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:country_id, :wastes_id, :materials_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  permit_params :country_id, waste_ids: [], material_ids: []
  #
  # or
  #
  # permit_params do
  #   permitted = [:country_id, :wastes_id, :materials_id]
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
    #
    def scoped_collection
      if current_admin_user.is_superadmin?
        resource_class
      else
        resource_class.includes(country_id: current_admin_user.country_id)
      end
    end
  end
  form do |f|
    f.inputs do
      f.input :country
      f.input :materials, as: :check_boxes
      f.inputs "Residuos" do
        f.input :wastes, as: :check_boxes
      end
    end
    f.actions
  end
end
