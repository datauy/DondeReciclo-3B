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

namespace :importer do
  task :routes,  [:country_id, :filename] => [:environment] do |_, args|
    #Params
    file = args[:filename].present? ? args[:filename] : 'motorecicladores-CO.geojson'
    #Set default to COL
    country = args[:country].present? ? args[:country] : 2
    #Load file
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    #mainMaterial = Material.find_by({:name => 'Materiales reciclables'})
    subprogram = SubProgram.find(982)
    f.each do |feature|
      if true #feature.properties['SUBPROGRAM'].present?
        #subprogram = SubProgram.find(feature.properties['SUBPROGRAM'])
        if feature.geometry.geometry_type.to_s == 'LineString'
          geo_factory = RGeo::Cartesian.factory()
          geom = geo_factory.multi_line_string([feature.geometry])
          puts "IMPORT LINE, FGT: #{geom.geometry_type}"
        else
          puts "NO IMPORT LINE, FGT: #{feature.geometry.geometry_type}"
          geom = feature.geometry
        end
        route_data = {
          name: feature.properties['Name'].present? ? "Motocargueros #{feature.properties['Name']}" : "Motocargueros #{feature.properties['BARRIO']}",
          route: geom
        }
        #materialId materiales reciclables
        route = Route.find_or_create_by(route_data)
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
        zone_data = {
          route: route,
          sub_program: subprogram,
          is_route: true,
          pick_up_type: args[:pick_up_type].present? ? args[:pick_up_type].to_i : 2,
          #information: zone_info
        }
        zone = Zone.find_or_create_by(zone_data)
        if !zone.validate!
          puts "ERROR: #{zone.errors.full_messages}\n next..."
          next
        else
          #Agregar schedules
          if (feature.properties['DIAS_DE_RE'].present? && feature.properties['HORARIO_DE'].present?)
            zone.schedule_ids = days_time(feature.properties['DIAS_DE_RE'], feature.properties['HORARIO_DE'])
            zone.save()
          end
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
        Location.create({
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
  task :routes,  [:country_id, :filename] => [:environment] do |_, args|
    #Params
    file = args[:filename].present? ? args[:filename] : 'deptos-CO.geojson'
    #Set default to COL
    country = args[:country_id].present? ? args[:country_id] : 2

  end
end
