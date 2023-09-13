class ApiController < ApplicationController
  before_action :set_locale

  def not_implemented
    render json: {error: "This function is not available for queried API version"}
  end

  #
  def zone4point
    factory = RGeo::GeoJSON::EntityFactory.instance
    features = []
    query_string = "*, locations.geometry as geometry, ROUND(ST_Distance( locations.geometry, ST_GeomFromText(:wkt) ) * 111000) as distance"
    Location.
    includes(:zones).
    select( ActiveRecord::Base::sanitize_sql_array([ query_string, wkt: params[:wkt] ]) ).
    order("distance asc").
    limit(1).
    each do |loc|
      features << factory.feature(loc.geometry, loc.id, { name: loc.name, subprograms: loc.zones.map { |zone| zone.sub_program.name} })
    end
    render json:
      RGeo::GeoJSON.encode(factory.feature_collection(features))
  end
  #
  def subprogram4location
    z = Zone.
    select("*, 0 as distance").
    includes( :schedules, :sub_program ).
    where(location_id: params[:zone])
    render json: formatZone(z, false)
  end
  #Location Subprograms
  def subprogramsInArea
    render json: SubProgram.
    joins(:locations).
    where( "ST_contains( locations.geometry, ST_GeomFromText(?) ) = true", params[:wkt] )
    .map{ |ns| {
      id: ns.id,
      name: ns.name,
      city: ns.city,
      address: ns.address,
      email: ns.email,
      phone: ns.phone,
      schedules: ns.receives.split('|'),
      locations: ns.locations.map{ |loc| loc.name },
      icon: ns.program.icon.attached? ? url_for(ns.program.icon) : nil
    }}
  end
  #Country by Point
  def country4Point
    render json: Country.
    where( "ST_contains( countries.geometry, ST_GeomFromText(?) ) = true", params[:wkt] ).
    pluck(:name)
    #where("ST_Contains(ST_Transform(ST_SetSRID(ST_GeomFromText('POINT(-75.2879 5.9671)'),4326),4326), ST_Transform(geometry,   4326))")
  end
  #Country by Point
  def location4Polygon
    factory = RGeo::GeoJSON::EntityFactory.instance
    features = []
    Location.
    distinct.
    includes(:zones).
    where( "ST_Intersects( locations.geometry, ST_PolygonFromText(?) ) = true", params[:wkt] ).
    each do |loc|
      features << factory.feature(loc.geometry, loc.id, { name: loc.name, subprograms: loc.zones.map { |zone| zone.sub_program.name} })
    end
    render json:
      RGeo::GeoJSON.encode(factory.feature_collection(features))
  end
  #
  def news
    qtty = 5
    offsetPage = params[:page].present? ? params[:page].to_i*qtty : 0;

    news = News
    if params[:country].present?
      news = News.
      where( :country_id => params[:country] ).
      or( News.where( :country_id => nil ))
    else
      news = News.all
    end
    render json: news.
      with_attached_images.
      order(id: :desc).
      offset(offsetPage).
      limit(qtty).
      map{ |ns| [ns.id, {
        id: ns.id,
        title: ns.title,
        summary: ns.summary,
        created_at: ns.created_at,
        images: ns.images.attached? ? [ url_for(ns.images.first)] : []
      }]}.to_h
  end
  #
  def new
    res = News.
      with_attached_images.
      find(params[:id])
    imgs = []
    if res.images.attached?
      res.images.map { |img|
        imgs << url_for(img)
      }
    end
    if ( params[:full].blank? )
      response = res.attributes.slice('information', 'video')
    else
      response = res.attributes
    end
    response["images"] = imgs
    render json: response
  end
  #
  def subprogram_containers
    @cont = Container
    .where( sub_program_id: params[:sub_ids].split(',') )
    .includes( :sub_program )
    render json: format_pins(@cont)
  end
  #
  def containers
    @cont = Container
    .with_attached_custom_icon
    .where( id: params[:container_ids].split(',') )
    .includes( :sub_program )
    render json: format_pins(@cont)
  end
  #
  def containers_bbox
    @cont = Container
      .with_attached_custom_icon
      .where(:hidden => false, :public_site => true)
      .within_bounding_box([ params[:sw].split(','), params[:ne].split(',') ])
      .includes( :sub_program )
    render json: format_pins(@cont)
  end
  #
  def containers_bbox4materials
    cont = Container
      .with_attached_custom_icon
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
  #
  def containers_nearby
    @cont = Container
      .with_attached_custom_icon
      .where(:hidden => false, :public_site => true)
      .near([params[:lat], params[:lon]], params[:radius], units: :km)
      .includes( :sub_program )
      .limit(50)
    render json: format_pins(@cont)
  end
  #
  def container_types
    render json: ContainerType
      .with_attached_icon
      .all
      .map{|cont| [cont.id, {
        id: cont.id,
        name: cont.name,
        class: cont.name.downcase.unicode_normalize(:nfkd).gsub(/[^\x00-\x7F]/n,'').gsub(/\s/,'-'),
        icon: cont.icon.attached? ? url_for(cont.icon) : ''
      }]}
      .to_h
  end
  #
  def materials
    render json: Material
      .includes(:icon_attachment)
      .all
      .map{|mat| [mat.id, {
      id: mat.id,
      name: mat.name,
      class: mat.name_class,
      color: mat.color,
      contrast_color: mat.contrast_color,
      icon: mat.icon.attached? ? url_for(mat.icon) : ''
    }]}
    .to_h
  end
  #
  def wastes
    if ( params[:ids] )
      render json: Waste
        .includes(:icon_attachment)
        .find(params[:ids].split(','))
        .map{|mat| ({
          id: mat.id,
          name: mat.name,
          class: mat.material.present? ? mat.material.name_class : 'primary',
          icon: mat.icon.attached? ? url_for(mat.icon) : ''
        })}
    else
      render json: {error: "Missing parameter :ids"}
    end
  end
  #
  def search_predefined
    country = 1 #load Uruguay/first by default
    country = params[:country] if params[:country]
    psearch = PredefinedSearch
      .where( :country_id => country )
      .first
    render json: format_search(
      Material
       .joins(:predefined_searches)
       .where( :"predefined_searches.id" => psearch.id ) +
      Waste
       .joins(:predefined_searches)
       .where( :"predefined_searches.id" => psearch.id )
    )
  end
  #
  def predefined_searches
    searches = []
    PredefinedSearch
    .includes( :country )
    .each do |p|
      searches << { p.country.name => format_search(
        Material
         .joins(:predefined_searches)
         .where( :"predefined_searches.id" => p.id ) +
        Waste
         .joins(:predefined_searches)
         .where( :"predefined_searches.id" => p.id )
        )
      }
    end
    render json: searches
  end
  #
  def programs
    # TODO: Fijarse cómo agregar un campo al objeto sin tener que mapear todo de nuevo :(
    country = 1 #load Uruguay/first by default
    country = params[:country] if params[:country]
    res = []
    Program.
    where(country_id: country).
      includes(:materials).
      includes(:supporters).
      includes(:wastes).
      includes(:locations).
      with_attached_logo.
      each do |prog|
        prog.logo_url = prog.logo.attached? ? url_for(prog.logo) : ""
        prog.materials_arr = prog.materials.map{ |mat| mat.id }
        prog.wastes_arr = prog.wastes.map{ |mat| mat.id }
        prog.locations_arr = prog.locations.map{ |loc| loc.name }.uniq
        prog.supporters_arr = prog.supporters.map{ |sup| {
          :name => sup.name,
          :url => sup.url
          }
        }
        prog.sub_programs_arr = prog.sub_programs.map{ |sp| sp.id }
        res << prog
      end
    render json: res
  end
  def programs_sum
    # TODO: Fijarse cómo agregar un campo al objeto sin tener que mapear todo de nuevo :(
    render json: Program.all.
      with_attached_icon.
      map{ |pg| [pg.id, {
      id: pg.id,
      name: pg.name,
      icon: pg.icon.attached? ? url_for(pg.icon) : ''
    }]}.to_h
  end
  # TODO: Pasar los subprogramas en la carga inicial ya que se repiten muchos datos, acá pasar sólo el subId
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
  # TODO: Pasar los subprogramas en la carga inicial ya que se repiten muchos datos, acá pasar sólo el subId
  private
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
      materials: cont.sub_program.materials.pluck(:id),
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
        wastes: ns.sub_program.wastes.ids,
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
  def not_implemented
    render json: {error: "This function is not available for queried API version"}
  end
end
