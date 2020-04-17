ActiveAdmin.register Product do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :information, :video, :barcode, waste_ids: []
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :information, :video, :barcode, :"#<ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition"]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  form do |f|
    f.inputs do
      f.input :name
      f.input :information
      f.input :video
      f.input :barcode
      f.input :wastes
    end
    f.actions
  end
end
