ActiveAdmin.register Waste do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :material_id, :name, :deposition, predefined_search_ids: []
  #
  # or
  #
  # permit_params do
  #   permitted = [:material_id, :name, :deposition]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index do
    selectable_column
    id_column
    column :name
    column :deposition
    column :image do |l|
      image_tag url_for(l.image) if l.image.attached?
    end
    column :material
    column "Prefefined Searches" do |l|
      l.predefined_searches.all.map { |e| [e.country.name] }.join(', ')
    end
    actions
  end
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :deposition, as: :ckeditor
      f.input :image, as: :file
      f.input :material, as: :select
      f.input :predefined_search_ids, :as => :check_boxes, :collection => PredefinedSearch.all.map{|m| [m.country.name, m.id]}
    end
    f.actions
  end
end
