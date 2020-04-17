ActiveAdmin.register Waste do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :material_id, :name, :deposition
  #
  # or
  #
  # permit_params do
  #   permitted = [:material_id, :name, :deposition]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
