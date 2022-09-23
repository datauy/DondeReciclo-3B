module V1
  class ApiController < ApplicationController
    before_action :set_locale
    #
    def containers_bbox
      @cont = Container
        .where(:hidden => false, :public_site => true)
        .within_bounding_box([ params[:sw].split(','), params[:ne].split(',') ])
        .includes( :sub_program )
      render json: format_pins(@cont)
    end
    #
    def containers_bbox4materials
      cont = Container
        .within_bounding_box([ params[:sw].split(','), params[:ne].split(',') ])
      if (params[:materials])
        @cont = cont.
          joins( sub_program: [:materials] ).
          where( :hidden => false, :public_site => true, :"materials_sub_programs.material_id" => params[:materials].split(',') )
      elsif params[:wastes]
        @cont = cont.
          joins( sub_program: [:wastes]).
          where( :hidden => false, :public_site => true, :"sub_programs_wastes.waste_id" => params[:wastes].split(',') )
      else
        return self.containers_bbox
      end
      render json: format_pins(@cont)
    end
    #Se tuvo que hacer la carga por partes dado que la consulta de near no responde en caso que el where opere sobre toda la consulta
    #Por o que se hace la primer carga de subprogramas eager y las consultas de materiales lazy
    def containers4materials
      cont = Container
        .includes( :sub_program )
        .near( [params[:lat], params[:lon]], 300, units: :km )
      if ( params[:materials] )
        materials = params[:materials].split(',')
        @cont = cont.
          joins( sub_program: [:materials] ).
          where( :hidden => false, :public_site => true, :"materials_sub_programs.material_id" => materials ).
          limit(50)
        #Search.create(coords: "POINT(#{params[:lat]} #{params[:lon]})", material_ids: materials)
      elsif params[:wastes]
        wastes = params[:wastes].split(',')
        @cont = cont.
          joins( sub_program: [:wastes] ).
          where( :hidden => false, :public_site => true, :"sub_programs_wastes.waste_id" => wastes ).
          limit(50)
        #Search.create(coords: "POINT(#{params[:lat]} #{params[:lon]})", waste_ids: wastes)
      else
        return self.containers_nearby
      end
      render json: format_pins(@cont)
    end
    #
    def search
      if ( params[:q].length > 2 )
        @str = params[:q]
        render json: format_search(
          Material.search(@str)+
          Waste.search(@str)+
          Product.search(@str)
        ).sort_by! {|r| r[:name]}
      else
        render json: {error: 'Insuficient parameter length, at least 3 charachters are required'}
      end
    end
    def not_implemented
      render json: {error: "This function is not available for queried API version"}
    end
    private
    def format_pins(objs)
      if params[:version] && params[:version].to_d >= 1.3
        return objs.map{|cont| ({
          id: cont.id,
          latitude: cont.latitude,
          longitude: cont.longitude,
          main_material: cont.sub_program.material_id,
          custom_icon: cont.custom_icon_active? && cont.custom_icon.attached? ? url_for(cont.custom_icon) : '',
        }) }
      else
        return objs.map{|cont| ({
          id: cont.id,
          #type_id: cont.container_type_id,
          #program_id: cont.sub_program.program_id,
          latitude: cont.latitude,
          longitude: cont.longitude,
          #program: cont.sub_program.program.name,
          #subprogram: cont.sub_program.name,
          #location: cont.site,
          #address: cont.address,
          #public: cont.public_site,
          #materials: cont.sub_program.materials.ids,
          #wastes: cont.sub_program.wastes.ids,
          main_material: cont.sub_program.material_id,
          class: cont.sub_program.material.name_class,
          #photos: [cont.photos.attached? ? url_for(cont.photos) : ''],  #.map {|ph| url_for(ph) } : '',
          #receives_no: cont.sub_program.receives_no
          custom_icon: cont.custom_icon_active? && cont.custom_icon.attached? ? url_for(cont.custom_icon) : '',
        }) }
      end
    end
    def format_container(cont)
      return {
        id: cont.id,
        type_id: cont.container_type_id,
        program_id: cont.sub_program.program_id,
        latitude: cont.latitude,
        longitude: cont.longitude,
        program: cont.sub_program.program.name,
        subprogram: cont.sub_program.name,
        site: cont.site,
        address: cont.address,
        location: cont.location,
        state: cont.state,
        public: cont.public_site,
        information: cont.information,
        materials: cont.sub_program.materials.ids,
        wastes: cont.sub_program.wastes.ids,
        main_material: cont.sub_program.material.id,
        class: cont.sub_program.material.name_class,
        photos: cont.photos.attached? ? cont.photos.map{|photo| url_for(photo)} : [],  #.map {|ph| url_for(ph) } : '',
        receives_no: cont.sub_program.receives_no,
        receives_text: cont.sub_program.receives,
        reception_conditions: cont.sub_program.reception_conditions,
        schedules: weekSummary(cont.schedules),
        custom_icon: cont.custom_icon_active? && cont.custom_icon.attached? ? url_for(cont.custom_icon) : '',
      }
    end
    def format_search(objs)
      res = []
      objs.each do |mat|
        oa = {
          id: mat.id,
          name: mat.name,
          deposition: nil,
          type: mat.class.name.downcase.pluralize,
          material_id: mat.id,
          class: nil,
          icon: mat.icon.attached? ? url_for(mat.icon) : '',
        }
        if mat.class.name == 'Material'
          oa[:deposition] = mat.information
          oa[:class] = mat.name_class
        elsif mat.class.name == 'Waste'
          oa[:material_id] = mat.material.nil? ? 0 : mat.material.id
          oa[:deposition] = mat.deposition
          oa[:class] = mat.material.present? ? mat.material.name_class : 'primary'
        elsif mat.class.name == 'Product'
          oa[:material_id] = mat.material.nil? ? 0 : mat.material.id
          oa[:class] = mat.material.present? ? mat.material.name_class : 'primary'
        end
        res << oa
      end
      return res
    end
    #
    def formatZone(z, load_geom)
      if params[:version] && params[:version].to_d >= 1.4
        return formatSubprogramZone(z, load_geom)
      end
      res = []
      z.each_with_index do |ns, i|
        res.push({
          id: ns.sub_program.id,
          program_id: ns.sub_program.program_id,
          name: ns.sub_program.name,
          city: ns.sub_program.city,
          address: ns.sub_program.address,
          email: ns.sub_program.email,
          phone: ns.sub_program.phone,
          action_title: ns.sub_program.action_title,
          action_link: ns.sub_program.action_link,
          receives: ns.sub_program.receives.present? ? ns.sub_program.receives.split('|') : [],
          locations: ns.sub_program.locations.map{ |loc| loc.name },
          #icon: ns.sub_program.program.icon.attached? ? url_for(ns.program.icon) : nil,
          zone: {
            is_route: ns.is_route,
            pick_up_type: ns.pick_up_type,
            schedules: ns.schedules,
          }
        })
        if load_geom
          factory = RGeo::GeoJSON::EntityFactory.instance
          res[i][:zone][:location] = RGeo::GeoJSON.encode(
            factory.feature_collection([
              factory.feature(
                ns.geometry,
                "#{ns.sub_program.id}-#{ns.id}",
                { name: ns.location.name, subprograms: [ns.sub_program.name] }
              )
            ])
          )
          res[i][:zone][:distance] = ns.distance
        end
      end
      logger.info("\n\n#{res.inspect}\n\n")
      return res
    end
    #
    def formatSubprogramZone(z, load_geom)
      res = {subprograms: [], locations: {}}
      locations = {}
      factory = RGeo::GeoJSON::EntityFactory.instance
      z.each_with_index do |ns, i|
        res[:subprograms].push({
          id: ns.sub_program.id,
          program_id: ns.sub_program.program_id,
          name: ns.sub_program.name,
          city: ns.sub_program.city,
          address: ns.sub_program.address,
          email: ns.sub_program.email,
          phone: ns.sub_program.phone,
          action_title: ns.sub_program.action_title,
          action_link: ns.sub_program.action_link,
          receives: ns.sub_program.receives.present? ? ns.sub_program.receives.split('|') : [],
          materials: ns.sub_program.materials.ids,
          locations: ns.sub_program.locations.map{ |loc| loc.name },
          #icon: ns.sub_program.program.icon.attached? ? url_for(ns.program.icon) : nil,
          zone: {
            location_id: ns.location_id,
            is_route: ns.is_route,
            pick_up_type: ns.pick_up_type,
            schedules: ns.schedules,
            distance: ns.distance,
            name: ns.location.name,
            information: ns.information,
          }
        })
        if load_geom
          #Rails.logger.debug { "\nACCCCCCCCCCCCCCAAAAAAAAAAAAAAAAAAAAAAAAA\n#{ns.geometry.inspect}\n\n" }
          if ( locations.key? ns.location_id )
            locations[ns.location_id].properties['subprograms'].push("#{ns.sub_program.name}, #{ns.distance} metros")
          else
            locations[ns.location_id] = factory.feature(
              ns.geometry,
              "#{ns.location_id}",
              { name: ns.location.name, subprograms: ["#{ns.sub_program.name}, #{ns.distance} metros"] }
            )
            #res[i][:zone][:distance] = ns.distance
          end
        end
      end
      res[:locations] = RGeo::GeoJSON.encode(
        factory.feature_collection(locations.values)
      )
      return res
    end
    #Format container week
    def weekSummary(scheds)
      res = {}
      scheds.each do |sched|
        if sched.closed
          res[sched.weekday] = {
            day: sched.weekday,
            closed: true
          }
        else
          day = {
            day: sched.weekday,
            start: sched.start.strftime('%H:%M'),
            end: sched.end.strftime('%H:%M'),
            closed: false
          }
          if res[sched.weekday].present? && res[sched.weekday][:closed].blank?
            if res[sched.weekday][:start] > day[:start]
              dayAux = res[sched.weekday]
              res[sched.weekday] = day.dup
              day = dayAux
            end
            res[sched.weekday]['start2'] = day[:start]
            res[sched.weekday]['end2'] = day[:end]
          else
            res[sched.weekday] = day
          end
        end
      end
      res
    end
    def set_locale
      I18n.locale = extract_locale || I18n.default_locale
    end
    def extract_locale
      parsed_locale = params[:locale]
      I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
    end
  end
end
