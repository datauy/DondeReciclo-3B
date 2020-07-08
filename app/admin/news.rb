ActiveAdmin.register News do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :information, :video, :summary, images: []
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :information, :video]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      f.input :title
      f.input :summary
      f.input :information
      f.input :images, as: :file, input_html: { multiple: true }
      f.input :video
    end
    f.actions
  end

end
