module V2
  class ApiController < ApplicationController
    before_action :set_locale

    #Location Subprograms
    def subprograms4location
      distance = 0.009
      distinct = false
      if params[:distance].present?
        distance = params[:distance]
      end
      select_query =  "zones.*, locations.geometry as geometry, ROUND(ST_Distance( locations.geometry, ST_GeomFromText(:wkt) ) * 111000) as distance"
      if params[:dimensions].present?
        where_query = 'materials.id in (:mids) and ST_DWithin( locations.geometry, ST_GeomFromText(:wkt), :distance )'
        mids = params[:dimensions].split(',')
        distinct = true
        z = Zone.
        joins(:location, sub_program: :materials).
        select( ActiveRecord::Base::sanitize_sql_array([ select_query, wkt: params[:wkt] ]) ).
        includes(:sub_program, :schedules).
        where( where_query, mids: mids, wkt: params[:wkt], distance: distance ).
        order("distance asc")
      else
        where_query = "ST_DWithin( locations.geometry, ST_GeomFromText(:wkt), :distance )"
        z = Zone.
        joins(:location).
        select( ActiveRecord::Base::sanitize_sql_array([ select_query, wkt: params[:wkt] ]) ).
        includes(:sub_program, :schedules).
        where( where_query, wkt: params[:wkt], distance: distance ).
        order("distance asc")
      end
      render json: formatSubprogramZone(z, true, distinct)
    end
    #
    def tags_programs
      country = 1 #load Uruguay/first by default
      country = params[:country] if params[:country]
      ptags = []
      Tag.where(section: 'programas').each do |tag|
        programs = []
        tag.programs.each do |p|
          if ( p.country_id == country )
            programs << {
              id: p.id,
              name: p.name,
              icon_url: p.icon.attached? ? url_for(p.icon) : ""
            }
          end
        end
        ptags << {name: tag.name, programs: programs}
      end
      render json: ptags
    end
    #
    def containers_bbox
      @cont = Container
        .within_bounding_box([ params[:sw].split(','), params[:ne].split(',') ])
        .includes( :sub_program, :custom_icon_attachment )
        .where(:hidden => false, :public_site => true)
      render json: format_pins(@cont)
    end
    #
    def containers_bbox4materials
      if ( params[:dimensions] )
        mids = params[:dimensions].split(',')
        #materials = Dimension.where( id: params[:dimensions].split(',') ).map {|dim| dim.materials.ids}.flatten
        #materials = Dimension.joins(:materials).select(:"materials.id").where( id: params[:dimensions].split(',') ).flat_map(&:id)
        wastes = Waste.includes(:material).where("materials.id": mids).pluck(:id)
        @cont = Container.distinct.
        within_bounding_box([ params[:sw].split(','), params[:ne].split(',') ]).
        includes(:sub_program, :custom_icon_attachment).
        joins(sub_program: [:materials, :wastes]).
        where( :hidden => false, :public_site => true, "materials_sub_programs.material_id": mids ).
        or(
          Container.distinct.
          within_bounding_box([ params[:sw].split(','), params[:ne].split(',') ]).
          includes(:sub_program, :custom_icon_attachment).
          joins(sub_program: [:materials, :wastes]).
          where( :hidden => false, :public_site => true, "sub_programs_wastes.waste_id": wastes )
        ).
        limit(50)
      else
        cont = Container.
          includes(:sub_program, :custom_icon_attachment).
          within_bounding_box([ params[:sw].split(','), params[:ne].split(',') ])
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
      end
      render json: format_pins(@cont)
    end
    #Se tuvo que hacer la carga por partes dado que la consulta de near no responde en caso que el where opere sobre toda la consulta
    #Por o que se hace la primer carga de subprogramas eager y las consultas de materiales lazy
    def containers4materials
      if ( params[:dimensions] )
        mids = params[:dimensions].split(',')
        #materials = Dimension.where( id: params[:dimensions].split(',') ).map {|dim| dim.materials.ids}.flatten
        #materials = Dimension.joins(:materials).select(:"materials.id").where( id: params[:dimensions].split(',') ).flat_map(&:id)
        wastes = Waste.includes(:material).where("materials.id": mids).pluck(:id)
        #close_to( params[:lat], params[:lon] ).
        @cont = Container.distinct.
        includes(:custom_icon_attachment, :sub_program ).
        near([params[:lat], params[:lon]], 300, units: :km).
        joins( sub_program: [:materials, :wastes] ).
        where( :hidden => false, :public_site => true, "materials_sub_programs.material_id": mids ).
        or(
          #close_to( params[:lat], params[:lon] ).
          Container.distinct.
          includes(:custom_icon_attachment, :sub_program ).
          near([params[:lat], params[:lon]], 300, units: :km).
          joins( sub_program: [:materials, :wastes]).
          where( :hidden => false, :public_site => true, "sub_programs_wastes.waste_id": wastes )
        ).
        limit(50)
      else
        cont = Container
        .includes( :custom_icon_attachment, :sub_program )
        .near( [params[:lat], params[:lon]], 300, units: :km )
        #Get dimension materials
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
        )
      else
        render json: {error: 'Insuficient parameter length, at least 3 charachters are required'}
      end
    end
    #
    def countries
      res = {}
      Country.includes(dimensions: :materials).each do |c|
        psearch = {}
        c.predefined_searches.each do |p|
          psearch[p.dimension_id] = format_search(
            Material
            .joins(:predefined_searches)
            .where( :"predefined_searches.id" => p.id ) +
            Waste
            .joins(:predefined_searches)
            .where( :"predefined_searches.id" => p.id )
          )
        end
        dimensions = []
        c.dimensions.each do |d|
          dimensions.push({
            id: d.id,
            name: d.name,
            color: d.color,
            information: d.information,
            materials: d.materials.pluck(:id)
          })
        end
        res[c.name] = {
          id: c.id,
          name: c.name,
          center:{lat: c.lat, lon: c.lon},
          code: c.code,
          locale: c.locale,
          dimensions: dimensions,
          predefinedSearch: psearch
        }
      end
      render json: res.values
    end
    #
    def dimensions
      render json: Dimension.all
    end
    #
    def search
      if ( params[:q].length > 2 )
        @str = params[:q]
        render json: format_search(
          Material.search( @str, params[:dimensions] ? params[:dimensions].split(',') : nil )+
          Waste.search(@str, params[:dimensions] ? params[:dimensions].split(',') : nil )
        )
      else
        render json: {error: 'Insuficient parameter length, at least 3 charachters are required'}
      end
    end
    def not_implemented
      render json: {error: "This function is not available for queried API version"}
    end
    # TODO: Pasar los subprogramas en la carga inicial ya que se repiten muchos datos, acá pasar sólo el subId
    private
    def format_pins(objs)
      return objs.map{|cont| ({
        id: cont.id,
        latitude: cont.latitude,
        longitude: cont.longitude,
        main_material: cont.sub_program.material_id,
        custom_icon: cont.custom_icon_active? && cont.custom_icon.attached? ? url_for(cont.custom_icon) : '',
      }) }
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
          color: nil,
          contrast_color: nil,
          icon: mat.icon.attached? ? url_for(mat.icon) : '',
        }
        if mat.class.name == 'Material'
          oa[:deposition] = mat.information
          oa[:class] = mat.name_class
          oa[:color] = mat.color
          oa[:contrast_color] = mat.contrast_color
        elsif mat.class.name == 'Waste'
          oa[:material_id] = mat.material.nil? ? 0 : mat.material.id
          oa[:deposition] = mat.deposition
          oa[:class] = mat.material.present? ? mat.material.name_class : 'primary'
          oa[:color] = mat.material.present? ? mat.material.color : nil
          oa[:contrast_color] = mat.material.present? ? mat.material.color : nil
        elsif mat.class.name == 'Product'
          oa[:material_id] = mat.material.nil? ? 0 : mat.material.id
          oa[:class] = mat.material.present? ? mat.material.name_class : 'primary'
          oa[:color] = mat.material.present? ? mat.material.color : nil
        end
        res << oa
      end
      return res.sort_by! {|r| r[:name]}
    end
    #
    def formatSubprogramZone(z, load_geom, norepeat)
      res = {subprograms: [], locations: {}}
      locations = {}
      zone_ids = []
      factory = RGeo::GeoJSON::EntityFactory.instance
      z.each_with_index do |ns, i|
        if zone_ids.include?(ns.id) && norepeat
          next
        else
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
            wastes: ns.sub_program.materials.ids.length == 0 ? ns.sub_program.wastes.ids : [],
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
          zone_ids.push(ns.id);
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
