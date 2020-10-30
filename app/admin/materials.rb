ActiveAdmin.register Material do
  permit_params :name, :icon, :information,:icon, :video, :color, predefined_search_ids: []

  index do
    selectable_column
    id_column
    column :name
    column :information
    column :icon do |l|
      image_tag url_for(l.icon) if l.icon.attached?
    end
    column :video
    column "Prefefined Searches" do |l|
      l.predefined_searches.all.map { |e| [e.country.name] }.join(', ')
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :information, as: :ckeditor
      f.input :icon, as: :file
      f.input :video
      f.input :predefined_search_ids, :as => :check_boxes, :collection => PredefinedSearch.all.map{|m| [m.country.name, m.id]}
    end
    f.actions
  end
end
