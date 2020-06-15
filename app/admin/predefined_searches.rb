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
  form do |f|
    f.inputs do
      f.input :country
      f.input :materials, as: :check_boxes
      #f.inputs "Residuos" do
      #  f.input :wastes, as: :check_boxes
      #end
    end
    f.actions
  end
end
