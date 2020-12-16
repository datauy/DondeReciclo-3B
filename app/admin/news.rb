ActiveAdmin.register News do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :information, :video, :summary, :country_id, images: []
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
      f.input :summary, as: :ckeditor
      f.input :information, as: :ckeditor
      f.input :images, as: :file, input_html: { multiple: true }
      f.input :video
      f.inputs "Country" do
        f.input :country_id, :as => :select, :collection => Country.all.map{|s| [s.name, s.id]}
      end
    end
    f.actions
  end

end
