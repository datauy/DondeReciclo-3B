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
      render json: Tag.
        includes(:programs).
        where(section: "programas", 'programs.country_id': country).
        map{|t| {name: t.name, total: t.programs.count} }.
        sort_by! {|r| r[:total]}.reverse!
    end
    def containers
      country = 1 #load Uruguay/first by default
      country = params[:country] if params[:country]
      res = []
      states = Location.where(country_id: country, loc_type: 'state')
      states.each do |state|
        state_count = Container.includes(sub_program: :program).where('programs.country_id': country).where("ST_within(ST_Point( containers.longitude, containers.latitude), (select geometry from locations where id = ?))", state.id).count
        res.push({
          name: state.name,
          total: state_count
        })
      end
      res.sort_by! {|r| r[:total]}.reverse!
      render json: res
    end
    def services
      country = 1 #load Uruguay/first by default
      country = params[:country] if params[:country]
      country_name = Country.find(country).name
      res = []
      states = Location.where(country_id: country, loc_type: 'state')
      national = Zone.includes(:location).where('locations.country_id': country, 'locations.loc_type': 'country').pluck(:id)
      states.each do |state|
        state_count = Zone.
          includes(sub_program: :program).
          left_joins(:location, :route).
          where.not(id: national).
          where('programs.country_id': country).
          where("ST_Intersects( locations.geometry, (select st_buffer(geometry, -0.001) from locations where id = :state) ) OR ST_Intersects( routes.route, (select st_buffer(geometry, -0.001) from locations where id = :state) )", state: state.id).
          count
        res.push({
          name: state.name,
          total: state_count
        })
      end
      res.sort_by! {|r| r[:total]}.reverse!
      #national at beginning
      res.unshift({name: country_name, total: national.length })
      render json: res
    end
    def users
      country = 1 #load Uruguay/first by default
      country = params[:country] if params[:country]
      render json: User.where('country_id': country).group(:state).count.map{|t| {name: t[0], total: t[1]} }.sort_by! {|r| r[:total]}.reverse!
    end
  end
end
