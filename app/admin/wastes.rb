ActiveAdmin.register Waste do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :material_id, :name, :deposition, :icon, predefined_search_ids: []
  #
  # or
  #
  # permit_params do
  #   permitted = [:material_id, :name, :deposition]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  before_action :authenticate, :set_locale
  menu if: proc{ current_admin_user.is_admin? }
  #
  controller do
    def authenticate
      if !current_admin_user.is_admin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
  end
  show do
    attributes_table do
      row :name
      row :material
      row :deposition
    end
  end

  filter :translations_name_contains, as: :string, label: "Nombre", placeholder: "Contiene"
  filter :translations_deposition_contains, as: :string, label: "Deposición", placeholder: "Contiene"
  filter :material
  filter :icon

  index do
    selectable_column
    id_column
    current_loc = I18n.locale
    I18n.available_locales.each do |loc|
      if loc != :en
        I18n.locale = loc
        column "Nombre #{loc}" do |obj|
          obj.name
        end
        column "Deposición #{loc}" do |obj|
          obj.deposition.present? ? obj.deposition.html_safe : ''
        end
      end
    end
    I18n.locale = current_loc
    #column (:name) { |waste| waste.translations.map{|tr| "#{tr.locale}: #{tr.name}".html_safe} }
    #column (:deposition) { |waste| waste.deposition.present? ? waste.deposition.html_safe : '' }
    column :icon do |l|
      image_tag url_for(l.icon) if l.icon.attached?
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
      current_loc = I18n.locale
      I18n.available_locales.each do |loc|
        if loc != :en && loc != current_loc
          I18n.locale = loc
          f.li "<b>Nombre #{loc}:</b> #{resource.name}".html_safe, class: "references"
          f.li "<b>Deposición #{loc}:</b> #{resource.deposition.present? ? resource.deposition.html_safe : ''}".html_safe, class: "references"
        end
      end
      I18n.locale = current_loc
      f.input :icon, as: :file
      f.input :material, as: :select
      f.input :predefined_search_ids, :as => :check_boxes, :collection => PredefinedSearch.all.map{|m| [m.country.name, m.id]}
    end
    f.actions
  end
  #
  csv do
    lastLocale = I18n.locale
    column :id
    I18n.locale = :es_UY
    column :name
    column :deposition do |waste|
      waste.deposition.gsub! '"', "'" if waste.deposition.present?
    end
    column('Nombre(CO)', humanize_name: false) do |waste|
      I18n.locale = :es_CO
      waste.name
    end
    column("Deposition(CO)", humanize_name: false) do |waste|
      waste.deposition.gsub! '"', "'" if waste.deposition.present?
    end
    column "Prefefined Searches" do |l|
      l.predefined_searches.all.map { |e| [e.country.name] }.join(', ')
    end
    column :material do |waste|
      I18n.locale = lastLocale
      waste.material.name
    end
  end
  #
  controller do
    def set_locale
      if current_admin_user.is_superadmin?
        if session[:current_country].present? && session[:current_country].to_i == 2
          I18n.locale = :es_CO
        else
          I18n.locale = I18n.default_locale
          session[:current_country] = 1
        end
      else
        if current_admin_user.country_id == 2
          I18n.locale = :es_CO
        else
          I18n.locale = I18n.default_locale
          session[:current_country] = 1
        end
      end
    end
  end
end
