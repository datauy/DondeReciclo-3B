ActiveAdmin.register Material do
  before_action :authenticate, :set_locale
  permit_params :name, :icon, :information,:icon, :video, :color, predefined_search_ids: []
  menu if: proc{ current_admin_user.is_admin? }
  #
  controller do
    def authenticate
      if !current_admin_user.is_admin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
  end
  #
  show do
    attributes_table do
      row :name
      row :information
      row :predefined_search_ids
    end
  end
  #
  filter :translations_name_contains, as: :string, label: "Nombre", placeholder: "Contiene"
  filter :translations_information_contains, as: :string, label: "Nombre", placeholder: "Contiene"
  filter :predefined_search_ids
  #
  index do
    selectable_column
    id_column
    column :name
    column (:information) { |mat| mat.information.present? ? mat.information.html_safe : '' }
    column :icon do |l|
      image_tag url_for(l.icon) if l.icon.attached?
    end
    column :video
    column "Prefefined Searches" do |l|
      l.predefined_searches.all.map { |e| [e.country.name] }.join(', ')
    end
    actions
  end
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :information, as: :ckeditor
      current_loc = I18n.locale
      I18n.available_locales.each do |loc|
        if loc != :en && loc != current_loc
          I18n.locale = loc
          f.li "<b>Nombre #{loc}:</b> #{resource.name}".html_safe, class: "references"
          f.li "<b>Información #{loc}:</b> #{resource.information.present? ? resource.information.html_safe : ''}".html_safe, class: "references"
        end
      end
      I18n.locale = current_loc
      f.input :icon, as: :file
      f.input :video
      f.input :predefined_search_ids, :as => :check_boxes, :collection => PredefinedSearch.all.map{|m| [m.country.name, m.id]}
    end
    f.actions
  end
  #
  csv do
    lastLocale = I18n.locale
    I18n.locale = I18n.default_locale
    column :id
    column :name
    column :information
    column('Nombre(CO)', humanize_name: false) do |mat|
      I18n.locale = :es_CO
      mat.name
    end
    column('Información(CO)', humanize_name: false) do |mat|
      mat.information
    end
    column "En búsqueda predefinida" do |l|
      I18n.locale = lastLocale
      l.predefined_searches.all.map { |e| [e.country.name] }.join(', ')
    end
  end

  controller do
    # TODO: Agregar idioma al país y levantarlo de manera correcta
    def set_locale
      if current_admin_user.is_superadmin?
        if session[:current_country].present? && session[:current_country].to_i == 2
          I18n.locale = :es_CO
        else
          I18n.locale = I18n.default_locale
        end
      else
        if current_admin_user.country_id == 2
          I18n.locale = :es_CO
        else
          I18n.locale = I18n.default_locale
        end
      end
    end
  end
end
