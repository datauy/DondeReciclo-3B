module V2
  class ApiStatsController < ApplicationController
    before_action :set_locale
    def set_locale
      I18n.locale = extract_locale || I18n.default_locale
    end
    def extract_locale
      parsed_locale = params[:locale]
      I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
    end
    #
    def totals
      country = 1 #load Uruguay/first by default
      country = params[:country] if params[:country].present?
      users = { title: "Usuarios", total: User.where(country_id: country).count }
      containers = { title: "Contenedores", total: Container.includes(sub_program: :program).where('programs.country_id': country).count }
      services = { title: "Servicios", total: Zone.includes(sub_program: :program).where('programs.country_id': country).count }
      programs = { title: "Programas", total: Program.where(country_id: country).count }

      render json: [ programs, containers, services, users ]
    end
    #
    def programs
      country = 1 #load Uruguay/first by default
      country = params[:country] if params[:country]
      render json: Tag.includes(:programs).where('programs.country_id': country).map{|t| {name: t.name, total: t.programs.count} }
    end
  end
end
