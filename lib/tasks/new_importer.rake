def all_day_sched
  #ids = []
  #for i in 1..7
      sched = {
        weekday: 0,
        start: '00:00',
        end: '23:59',
        desc: "24 horas"
    }
    schedule = Schedule.find_or_create_by(sched)
    #ids << schedule.id
  #end
  return [schedule.id]
end
def working_days_sched
  sched = {
    weekday: 8,
    start: '09:00',
    end: '21:00',
    desc: "Todos los días de 9 a 21"
  }
  schedule = Schedule.find_or_create_by(sched)
  return [schedule.id]
end

def days_time(rdays, rtime)
  ids = []
  wdays = ['Todos', 'L', 'M', 'Mi', 'J', 'V', 'S', 'D' ]
  rdays_indexes = rdays.split(',').map{|d| wdays.find_index(d) }
  rtime_arr = rtime.split(" a ")
  for i in rdays_indexes
    sched = {
    weekday: i,
    start: rtime_arr[0],
    end: rtime_arr[1].present? ? rtime_arr[1] : rtime_arr[0],
    desc: "#{rdays} - #{rtime}"
    }
    schedule = Schedule.find_or_create_by(sched)
    ids << schedule.id
  end
  return ids
end
def update_subprogram_locations()
  #Subprogram Locations
  subLocations = subprogram.locations.ids
  # TODO: ACOMODAR LOCALIDADES
  if feature.properties['CIUDAD'].present?
    city = Location.find_or_create_by({
      name: feature.properties['CIUDAD'].strip,
      loc_type: 'city',
      country_id: country
    })
    if !( city.id.in? subLocations)
      subprogram.locations.push(city)
    end
  end
  if feature.properties['LOCALIDAD'].present?
    mun = Location.find_or_create_by({
      name: feature.properties['LOCALIDAD'].strip,
      loc_type: 'municipality',
      parent_location_id: city.present? ? city.id : nil,
      country_id: country
    })
    if !( mun.id.in? subLocations)
      subprogram.locations.push(mun)
    end
  end
  if feature.properties['BARRIO'].present?
    nei = Location.find_or_create_by({
      name: feature.properties['BARRIO'].strip,
      loc_type: 'neighborhood',
      parent_location_id: mun.present? ? mun.id : nil,
      country_id: country
    })
    if !( nei.id.in? subLocations)
      subprogram.locations.push(nei)
    end
  end
  # TODO: Agregar materiales a subprograma
  if feature.properties['TIPO_DE_MA'].present?
    subprogram.add_wastes_or_materials(feature.properties['TIPO_DE_MA'].split(','), false)
  end
  subprogram.save();
end

def add_route(name, feature, sub_id, pick_up_type = 2, color = nil, custom_active = false)
  if feature.geometry.geometry_type.to_s == 'LineString'
    geo_factory = RGeo::Cartesian.factory()
    geom = geo_factory.multi_line_string([feature.geometry])
    puts "IMPORT LINE, FGT: #{geom.geometry_type}"
  else
    puts "NO IMPORT LINE, FGT: #{feature.geometry.geometry_type}"
    geom = feature.geometry
  end
  route_data = {
    name: name,
    route: geom
  }
  #materialId materiales reciclables
  route = Route.find_or_create_by(route_data)
  zone_data = {
    route: route,
    sub_program_id: sub_id,
    is_route: true,
    pick_up_type: pick_up_type,
    #information: zone_info,
  }
  
  zone = Zone.find_or_create_by(zone_data)
  if !zone.validate!
    puts "ERROR: #{zone.errors.full_messages}\n next..."
    return
  else
    #Agregar schedules
    if (feature.properties['DIAS_DE_RE'].present? && feature.properties['HORARIO_DE'].present?)
      zone.schedule_ids = days_time(feature.properties['DIAS_DE_RE'], feature.properties['HORARIO_DE'])
    end
    zone.color = color if color.present?
    if custom_active
      zone.custom_active = custom_active
      zone.icon_start.attach(io: File.open("#{Rails.root}/app/assets/images/motocargueros.svg"), filename: 'motocargueros.svg', content_type: 'image/svg+xml')
      zone.icon_end.attach(io: File.open("#{Rails.root}/app/assets/images/motocargueros.svg"), filename: 'motocargueros.svg', content_type: 'image/svg+xml')
    end
    zone.save()
  end
end

###### IMPORTER ###########3
#
namespace :importer do
  task :routes,  [:subp_id, :filename] => [:environment] do |_, args|
    if args[:subp_id].present?
      subp_id = args[:subp_id]
      #Params
      file = args[:filename].present? ? args[:filename] : 'limpieza-de-playas1-rutas-CO.geojson'
      #Load file
      f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
      #mainMaterial = Material.find_by({:name => 'Materiales reciclables'})
      #subprogram = SubProgram.find(1009)
      f.each do |feature|
        if true #feature.properties['SUBPROGRAM'].present?
          #subprogram = SubProgram.find(feature.properties['SUBPROGRAM'])
          name = feature.properties['Name'].present? ? feature.properties['Name'] : "Motocargueros"
          add_route(name, feature, subp_id)
        end
      end
    end
  end
  #
  task :add_locations,  [:filename, :loc_type, :country, :parent_id] => [:environment] do |_, args|
    p "Starting IMPORT"
    file = args[:filename].present? ? args[:filename] : 'deptos_col.geojson'
    loc_type = args[:loc_type].present? ? args[:loc_type] : 'state'
    country = args[:country].present? ? args[:country] : 2
    if args[:parent_id].present?
      parent_id = args[:parent_id]
    else
      parent_id = Location.where(loc_type: "country", country_id: country).first.id
    end
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    f.each do |feature|
      loc = Location.find_by(name: feature.properties['name'])
      if loc.present?
        p "LOCATION FOUND: #{loc.id}"
      else
        Location.find_or_create_by({
          name: feature.properties['name'],
          geometry: feature.geometry,
          loc_type: loc_type,
          country_id: country,
          parent_location_id: parent_id
        })
        p "\n LOCATION CREATED: #{feature.properties['name']}"
      end
    end
  end
  #
  task :import_routes,  [:country_id, :filename] => [:environment] do |_, args|
    file = args[:filename].present? ? args[:filename] : 'deptos-CO.geojson'
    #Set default to COL
    country = args[:country_id].present? ? args[:country_id] : 2
    #load dir
    Dir.glob("#{Rails.root}/db/data/import_files/*") do |file|
      p "Getting File: #{file}"
      file_name = file.split('/')[-1]
      f = RGeo::GeoJSON.decode(File.read( "db/data/import_files/#{file_name}" ))
      a = JSON.parse(File.read( "db/data/import_files/#{file_name}" ))
      name = a["name"]
      sub_id = 1009
      f.each do |feature|
        add_route(name, feature, sub_id, 2, '#f40009', true)
      end
    end
  end
  #
  task :import_canelones, [:dir, :program_id] => [:environment] do |_, args|
    dir = args[:dir].present? ? args[:dir] : 'canelones_uy'
    program_id = args[:program_id].present? ? args[:program_id] : 65
    Dir.glob("#{Rails.root}/db/data/import_files/kmls/#{dir}/*") do |file|
      #file = "/home/fernando/PROJECTS/DATA/DondeReciclo-3B/db/data/import_files/kmls/canelones_uy/MUNICIPIO DE CIUDAD DE LA COSTA.kml"
      kml = Nokogiri::XML(File.open(file))
      #puts kml.inspect
      #name = kml.css("Document name").first.text
      i = 0
      kml.css("Folder").each do |fol|
        sub_name = fol.css("name").first.text.strip
        if sub_name.include?('RECOLECCIÓN DE RESTOS VEGETALES') || sub_name.include?('RECICLAJE - ECOPUNTOS')
          if sub_name.include? 'RECICLAJE - ECOPUNTOS'
            sub_name = 'RECICLAJE - ECOPUNTOS'
            materials = Material.find([1,2,3])
            material = 6
          else
            sub_name = 'RECOLECCIÓN DE RESTOS VEGETALES'
            materials = [Material.find(7)]
            material = 7
          end
          sub_prog = {
            program_id: 65,
            name: sub_name,
            full_name: sub_name,
            material_id: material,
          }
          sub_program = SubProgram.find_or_create_by(sub_prog)
          if !sub_program.validate!
            puts "ERROR: #{sub_program.errors.full_messages}\n next..."
            next
          else
            sub_program.materials = materials
            sub_program.save
          end
          puts "Processing #{sub_name} in #{file}" 
          process_kml_folder(fol, sub_program)
        end
      end
    end
  end
  task :containers_json, [:subp_id, :filename] => [:environment] do |_, args|
    if args[:subp_id].present?
      subp_id = args[:subp_id]
      file = args[:filename].present? ? args[:filename] : 'limpieza-de-playas1-puntos-CO.geojson'
      #Load file
      f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
      #mainMaterial = Material.find_by({:name => 'Materiales reciclables'})
      f.each do |feature|
        container = {
          site: feature.properties["Name"].present? ? feature.properties["Name"] : '',
          latlon: feature.geometry,
          latitude: feature.geometry.coordinates[1],
          longitude: feature.geometry.coordinates[0],
          location:  feature.properties["ciudad"].present? ? feature.properties["ciudad"]: '',
          address: feature.properties["Dirección"].present? ? feature.properties["Dirección"] : '',
          public_site: 1,
          sub_program_id: subp_id,
          site_type: feature.properties["site_type"] == "Espacio Público" ? "En vía pública" : "",
          container_type_id: feature.properties["CT"].present? ? feature.properties["CT"] : 3,
        }
        container = Container.find_or_create_by(container)
        if !container.validate!
          puts "ERROR: #{container.errors.full_messages}\n exiting..."
          next
        end
      end
    else
      puts "ERROR: no suprogram selected\n exiting..."
    end
  end
  def process_kml_folder(kml, sub_program)
    geo_factory = RGeo::Cartesian.factory()
    kml.css("Placemark").each do |pm|
      geo_name = pm.css("name").first.text
      geo_desc = pm.css("description").first.present? ? pm.css("description").first.text : ''
      
      zone_data = {
        location: nil,
        route: nil,
        sub_program: sub_program,
        is_route: false,
        pick_up_type: 1,
        information: geo_desc
      }
      polygon = pm.css("Polygon")
      if polygon.present?
        ring = []
        coords = polygon.css("coordinates").first
        if coords.present?
          coords.
          text.split("\n").
          map {|l| l.strip.split(',')}.
          reject! { |c| c.empty? }.each do |coord|
            ring << geo_factory.point(coord[0], coord[1]) 
          end
          outerring = geo_factory.linear_ring(ring)
          poly = geo_factory.polygon(outerring)
          geometry = geo_factory.multi_polygon([poly])
          loc = {
            name: geo_name,
            geometry: geometry,
            country_id: 1,
            loc_type: 5
          }
          loc = Location.find_or_create_by(loc)
          #asume area, adding municipality
          add_location_parent(loc, 3, 1)
          zone_data[:location] = loc
          zone = Zone.find_or_create_by(zone_data)
          if !zone.validate!
            puts "ERROR: #{zone.errors.full_messages}\n next..."
            next
          end
        end
      else
        linestr = pm.css("LineString")
        if linestr.present?
          puts "LINE STRING"
          line_points = []
          coords = linestr.css("coordinates").first
          if coords.present?
            coords.
            text.split("\n").
            map {|l| l.strip.split(',')}.
            reject! { |c| c.empty? }.each do |coord|
              line_points << geo_factory.point(coord[0], coord[1])
            end
            line_string = geo_factory.line_string(line_points)
            geometry = geo_factory.multi_line_string([line_string])
          end
          route_data = {
            name: geo_name,
            route: geometry
          }
          #materialId materiales reciclables
          route = Route.find_or_create_by(route_data)
          zone_data[:route] = route
          zone_data[:is_route] = true
          zone = Zone.find_or_create_by(zone_data)
          if !zone.validate!
            puts "ERROR: #{zone.errors.full_messages}\n next..."
            next
          end
        else
          point_data = pm.css("Point coordinates").first
          if point_data.present?
            coord = point_data.text.strip.split(',')
            container = Container.find_or_create_by({
              sub_program_id: sub_program.id,
              latitude: coord[1],
              longitude: coord[0],
              container_type_id: 1,#ctypes[row[8]],
              public_site: 1,
              #site_type: row[6],
              site: geo_name,
              information: geo_desc
            })
            if !container.validate!
              puts "ERROR: #{zone.errors.full_messages}\n next..."
              next
            end
          end
        end
      end
      #puts poly.inspect
    end
  end
  def add_location_parent(loc, parent_type, cid)
    if loc.parent_location_id.nil?
      p "Processing parent location: #{loc.id} - #{loc.loc_type} - #{loc.name}"
      parent_id = Location.
      where( loc_type: parent_type, country_id: cid ).
      where( "ST_Intersects( st_buffer(geometry, -0.001), (select geometry from locations where id = :loc) )", loc: loc.id).
      pluck(:id)
      if ( parent_id.present? )
        p "Updating Parent location #{parent_id}"
        loc.update(parent_location_id: parent_id.first)
      else
        p "No state found"
      end
    else
      p "Parent location already set: #{loc.id} - #{loc.loc_type} - #{loc.name}"
    end
  end
end
