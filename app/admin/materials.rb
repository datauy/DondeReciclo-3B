ActiveAdmin.register Material do
  before_action :set_locale
  permit_params :name, :icon, :information,:icon, :video, :color, predefined_search_ids: []

  show do
    attributes_table do
      row :name
      row :information
      row :predefined_search_ids
    end
  end

  filter :translations_name_contains, as: :string, label: "Nombre", placeholder: "Contiene"
  filter :translations_information_contains, as: :string, label: "Nombre", placeholder: "Contiene"
  filter :predefined_search_ids

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

  controller do
    def set_locale
      if session[:current_country].present? && session[:current_country].to_i == 2
        I18n.locale = :es_CO
      else
        I18n.locale = :es
      end
    end
  end
end
