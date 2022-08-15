ActiveAdmin.register Dimension do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :information, :color, country_ids: []
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :information, :color]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form :html => { :multipart => true } do |f|
    inputs do
      f.input :name
      f.input :information
      f.input :color, input_html: { class: 'colorpicker' }
      f.input :countries, as: :check_boxes
    end
    f.actions
  end
end
