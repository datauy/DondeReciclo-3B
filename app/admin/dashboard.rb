ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span "Bienvenide #{current_admin_user.email}"
        small "En el panel de administración podrá gestionar la información del país en el que se encuentra. Para seleccionar el país tenga a bien elejirlo de la lista debajo."
      end
      div class: "country-select" do
        span "Selecciona un país"
        div class: "buttons" do
          if params[:country_id].present?
            session[:current_country] = params[:country_id]
          end
          Country.all.map do |ctry|
            a "#{ctry.name}",
              id: "country-#{ctry.id}",
              class: "button #{session[:current_country].to_i == ctry.id ? 'selected' : ''}",
              href: admin_dashboard_path({country_id: ctry.id}),
              as: :button
          end
        end
      end
    end

    columns do
      column do
        panel "Contenedores por país" do
          ul do
            Container.
            joins(sub_program:[:program]).
            group("programs.country_id").
            count.
            map do |country_id, qtty|
              li "#{Country.find(country_id).name}: #{qtty}"
            end
          end
        end
      end
    end
  end # content
end
