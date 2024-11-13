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
namespace :importer_col do
  I18n.locale = :es_CO
  #
  task :assign_programs_fromCSV, [:file] => :environment do |_, args|
    file = args[:file].present? ? args[:file] : 'PuntosProgramas.csv'
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    programs = {}
    not_found = []
    CSV.foreach("db/data/#{file}", headers: true) do |feature|
      sub_prog = {
        city:  feature["Ciudad"],
        email: feature["Correo"],
        name: feature["Responsabl"],
      }
      sub_program = SubProgram.find_by(sub_prog)
      if sub_program.present?
        prog = feature["PROGRAMA"]
        program = Program.find_or_create_by( {
          name: prog,
          country_id: 2
        })
        if programs[prog].present?
          if !programs[prog].include?(sub_program.id)
            programs[prog] << sub_program.id
            sub_program.program = program
            sub_program.save
            puts "Subprogram update: #{sub_program.name}, program  #{program.name}, #{feature["Ciudad"]}"
          end
        else
          programs[prog] = [sub_program.id]
          sub_program.program = program
          sub_program.save
          puts "Subprogram update: #{sub_program.name}, program  #{program.name}, #{feature["Ciudad"]}"
        end
      else
        puts "SUBP NOT FOUND: #{feature["Responsabl"]}"
        if !not_found.include?(feature["Responsabl"])
          not_found << feature["Responsabl"]
        end
      end
    end
    puts "\n\nTERMINADO: \n #{programs.inspect}\nNo encontrados\n#{not_found.inspect}\n"
  end
  #
  task :assign_programs, [:file] => :environment do |_, args|
    file = args[:file].present? ? args[:file] : 'posconsumo.geojson'
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    f.each do |feature|
      sub_prog = {
        city:  feature.properties["Ciudad"],
        email: feature.properties["Correo"],
        name: feature.properties["Responsabl"],
      }
      sub_program = SubProgram.find_by(sub_prog)
      if sub_program.present?
        program = Program.find_or_create_by( {
          name: feature.properties["Responsabl"],
          country_id: 2
        })
        sub_program.program = program
        sub_program.save
        puts "Subprogram update: #{sub_program.name}, program  #{program.name}"
      else
        puts "SUBP NOT FOUND: #{feature.properties["Responsabl"]}"
      end
    end
  end
  #
  task :eval_materials, [:file] => :environment do |_, args|
    file = args[:file].present? ? args[:file] : 'posconsumo.geojson'
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    mats = []
    f.each do |feature|
      mats << [feature["Responsabl"], feature["Tipo_de_Ma"]]
    end
    mats.uniq.each do |a|
      mat = Waste.where({name: a[1]}).first
      if (mat.present?)
        puts "MATERIAL PRESENT CO: #{mat.name}"
      end
      puts "#{a[0]} => #{a[1]}"
    end
  end
  task :containers, [:file] => :environment do |_, args|
    file = args[:file].present? ? args[:file] : 'contenedores_colombia.geojson'
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    puts "Empieza importación de puntos: #{file}"
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    i = 0
    site_name = 'Nombre_lug'
    collect = 'Dias_recol'
    collect_time = 'Horario_at'
    ciudad = 'Ciudad'
    info = nil
    program_key = 'Responsabl'
    sub_program_key = 'Responsabl'
    container_type = 3
    if file == 'posconsumo.geojson' || file == 'posconsumo-test.geojson'
      site_name = 'Nombre_Pun'
      collect = 'Dias_de_re'
      collect_time = 'Horario'
    end
    if file == 'faro.geojson'
      collect = 'Días_de_r'
      collect_time = 'Horario_de'
      program_id = 11
    end
    if file == 'valorBog.geojson'
      site_name = 'Identifica'
      program_id = 11
      ciudad = 'Departamen'
      info = 'Horario'
      program_key = 'Programa__'
      sub_program_key = 'Sub_progra'
      container_type = 15
    end
    allDayIds = all_day_sched();
    f.each do |feature|
      i = i + 1
      puts "Contenedor #{i}\n"
      if program_id.present?
        program = Program.find(program_id)
      else
        program = Program.find_or_create_by( {
          name: feature.properties[program_key],
          country_id: 2
          })
      end
      sub_prog = {
        program: program,
        city:  feature.properties[ciudad],
        email: feature.properties["Correo"],
        name: feature.properties[sub_program_key],
      }
      sub_program = SubProgram.find_by(sub_prog)
      if sub_program.nil?
        ## TODO: Agregar material principal en importación
        sub_prog[:material_id] = 6
        sub_program = SubProgram.create(sub_prog)
        if !sub_program.validate!
          puts "ERROR Subprogram: #{sub_program.errors.full_messages}\n exiting..."
          next
        end
      end
      waste_names = feature["Residuos"]
      sub_errors = sub_program.add_wastes_or_materials(waste_names.split(','), false)
      puts "\nError en materiales/residuos #{sub_errors.inspect}\n"
      if feature.properties['Condicione'].present?
        sub_program.reception_conditions = feature.properties['Condicione']
      end
      sub_program.save
      #Los materiales se asocian manualmente a los subprogramas
      container = {
        site: feature.properties[site_name].present? ? feature.properties[site_name] : '',
        latlon: feature.geometry,
        latitude: feature.geometry.coordinates[1],
        longitude: feature.geometry.coordinates[0],
        location:  feature.properties[ciudad],
        address: feature.properties["Dirección"],
        public_site: 1,
        sub_program_id: sub_program.id,
        site_type: feature.properties[site_name] == "Espacio Público" ? "En vía pública" : "",
        container_type_id: container_type,
      }
      container = Container.find_or_create_by(container)
      if !container.validate!
        puts "ERROR: #{container.errors.full_messages}\n exiting..."
        next
      end
      if feature.properties["Id"].present?
        container[:external_id] = feature.properties["Id"]
      end
      if info.present?
        container.information = feature.properties[info]
      elsif (feature.properties[collect].present? && feature.properties[collect_time].present?)
        container.information = "Dias de recolección: #{feature.properties[collect]} \nHorario: #{feature.properties[collect_time]}"
      end
      container.save
      #Get schedules
      scheds = []
      if feature.properties["Horario_at"]  == 'Permanente' && feature.properties["Funcionami"] == 'Permanente'
        scheds = allDayIds
        puts "Asignado automáticamente el calendario para todos los días\n"
      end
      container.schedule_ids = scheds
      container.save
    end
    puts "\n\nSe importaron #{i} contenedores_colombia\n"
  end
  #
  task :update_zones  => :environment do
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    SubProgram.
    joins(:locations).
    each do |subs|
      subs.locations.each do |loc|
        puts "\nZONE:::\n#{loc.inspect}\n"
        zone_data = {
          location: loc,
          sub_program: subs,
          is_route: FALSE,
          pick_up_type: 1
        }
        zone = Zone.find_or_create_by(zone_data)
        if !zone.validate!
          puts "ERROR: #{zone.errors.full_messages}\n next..."
          next
        end
      end
    end
  end
  task :routes, [:filename, :pick_up_type, :file_type]  => :environment do |_, args|
    puts "\n\nARGS: #{args[:filename]} - #{args[:pick_up_type]} - #{args[:file_type]}\n\n"
    address = "Dirección"
    email = "Correo"
    materials = "Materiales"
    location = "Cobertura"
    org = "Organizaci"
    conditions = "Condiciones"
    zone_info = ''
    if args[:file_type].present? && args[:file_type] == "2"
      puts "\n\nENTRA A TYPE2\n\n"
      address = "Direcci_Or"
      email = "Correo_ele"
      materials = "TipoMateri"
      location = "Barrio_Zon"
      org = "Asociació"
      conditions = 'Condicione'
    end
    filename = args[:filename].present? ? args[:filename] : 'costa'
    f = RGeo::GeoJSON.decode(File.read("db/data/#{filename}.geojson"))#, json_parser: :json, geo_factory: RGeo::Geographic.simple_mercator_factory)
    mainMaterial = Material.find_by({:name => 'Materiales reciclables'})
    f.each do |feature|
      loc = {
        name: feature.properties[location],
        geometry: feature.geometry#factory.multi_polygon([feature.geometry])
      }
      #materialId materiales reciclables
      loc = Location.find_or_create_by(loc)
      sub_prog = {
        program_id: 11,
        city:  feature.properties["Ciudad"],
        address: feature.properties[address],
        email: feature.properties[email],
        phone: feature.properties["Teléfono"],
        name: feature.properties[org],
        full_name: feature.properties["OR_"].present? ? feature.properties["OR_"] : feature.properties[org],
        material: mainMaterial,
      }
      if feature.properties[conditions].present?
        sub_prog['reception_conditions'] = feature.properties[conditions]
      end
      puts sub_prog.inspect
      sub_program = SubProgram.find_or_create_by(sub_prog)
      if !sub_program.validate!
        puts "ERROR: #{sub_program.errors.full_messages}\n next..."
        next
      end
      if args[:file_type].present? && args[:file_type] == "2"
        zone_info = "#{feature.properties[location]}: #{feature.properties["Frecuencia"]} - #{feature.properties["Hora_Inici"]} a #{feature.properties["Hora_Fin"]}"
      end
      zone_data = {
        location: loc,
        sub_program: sub_program,
        is_route: true,
        pick_up_type: args[:pick_up_type].present? ? args[:pick_up_type].to_i : 2,
        information: zone_info
      }
      zone = Zone.find_or_create_by(zone_data)
      if !zone.validate!
        puts "ERROR: #{zone.errors.full_messages}\n next..."
        next
      end
      # TODO: Agregar calendarios
      if feature.properties[materials].present?
        sub_errors = sub_program.add_wastes_or_materials(feature.properties[materials].split(','), true)
        puts "\nError en materiales/residuos #{sub_errors.inspect}\n"
      end
    end
    #end
  end
  #
  task :countries  => :environment do
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    f = RGeo::GeoJSON.decode(File.read('db/data/Uruguay-Colombia.geojson'))
    f.each do |feature|
      name = {
        name: feature.properties["COUNTRY"],
      }
      country = Country.find_or_create_by(name)
      country.geometry = feature.geometry
      country.save
    end
  end
  task :test  => :environment do
    Country.all.each do |country|
      puts country.name
    end
  end
end

namespace :importer_uy do
  task :conciliate_locations,  [:filename] => [:environment] do |_, args|
    p "Starting IMPORT"
    file = args[:filename].present? ? args[:filename] : 'deptos-UY-2022.geojson'
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    f.each do |feature|
      del = true
      p "\n #{feature.properties['name']}"
      #Get depto
      old_ids = Location.select(:id).where(name: feature.properties['name']).ids
      if feature.properties['name'] == "Montevideo"
        del = false
        old_ids.push(355)
      end
      p old_ids.inspect
      new_loc = Location.create(name: feature.properties['name'], geometry: feature.geometry)
      p "Nuevo ID #{new_loc.id}"
      old_ids.each do |oid|
        LocationRelation.where(location_id: oid).update(location_id: new_loc.id)
        Zone.where(location_id: oid).update(location_id: new_loc.id)
        Location.delete(oid) if del
      end
    end
  end
  task :locations,  [:filename, :loc_type] => [:environment] do |_, args|
    file = args[:filename].present? ? args[:filename] : 'deptos-UY.geojson'
    loc_type = args[:loc_type].present? ? args[:loc_type] : 3
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    f.each do |feature|
      if feature.properties['code'].present?
        code = feature.properties['code']
        depto = Location.find_by({name: feature.properties['name'], code: code})
      else
        depto = Location.find_by({name: feature.properties['name']})
        code = ''
      end
      if depto.present?
        depto.geometry = feature.geometry
        depto.save
        if depto.errors
          puts "ERROR EN #{depto.name}: \n #{depto.errors.inspect}"
        else
          puts "DEPTO ACTULIZADO  #{depto.name}"
        end
      else
        loc = {
          name: feature.properties["name"],
          geometry: feature.geometry,
          code: code,
          loc_type: loc_type
        }
        puts "LOCATION CREATE #{feature.properties["name"]}"
        Location.create(loc)
      end
    end
  end
  task :drugstores, [:version] => [:environment] do |_, args|
    containers = []
    CSV.foreach('db/data/Farmacias-Veterinarias-PLESEM.csv', headers: true) do |row|
      containers << {
        public_site: 1,
        hidden: 0,
        state: row[2],
        site: row[0],
        address: row[1],
        location: nil,
        external_id: nil,
        sub_program_id: 4,
        site_type: 'Farmacia',
        latitude: row[4],
        longitude: row[5],
        container_type_id: 11,
      }
    end
    #puts containers.inspect
    Container.import containers
  end
  task :montevideo, [:version] => [:environment] do |_, args|
    containers = []
    externals = []
    external_objs = {}
    contDR = Container.where({sub_program_id: [13, 14, 10, 12], state: 'Montevideo'})
    CSV.foreach('db/data/contenedores_reciclables-montevideo.csv', headers: true) do |row|
      externals << row[0]
      external_objs[row[0]] = row
    end
    i = 0
    j = 0
    contDR.each do |cont|
      if external_objs[cont.external_id].present?
        if external_objs[cont.external_id][1] != cont.site
          puts " TIENE EXTERNAL NO COINCIDE NOMBRE: #{cont.inspect}"
          j = j + 1
        end
      else
        puts " NO TIENE EXTERNAL: #{cont.inspect}"
        i = i + 1
      end
    end
    puts "No tienen external #{i}, no conicide nombre #{j}"

=begin
contRemain = Container.where({external_id: externals, state: 'Montevideo'}).pluck(:external_id)
externals << ''
externals << nil
#Change point proj
#srs_database = RGeo::CoordSys::SRSDatabase::Proj4Data.new('epsg', cache: true)
#factory_32721 = RGeo::Cartesian.factory(srid: 32721, srs_database: srs_database)
#factory_4326 = RGeo::Geographic.spherical_factory(srid: 4326, srs_database: srs_database)
#Get each new record from list
external_objs.except!(contRemain).each do |row|
puts row
#point_32721 = factory_32721.point()
#point_4326 =  RGeo::Feature.cast(point_32721, factory: factory_4326, project: true)
#puts point_4326.inspect
sql = "SELECT ST_AsText(ST_Transform(ST_GeomFromText('POINT(#{row[4]} #{row[5]})',32721),4326)) As wgs_geom";
lala = ActiveRecord::Base.connection.execute(sql)
puts lala
containers << {
public_site: 1,
hidden: 0,
state: 'Montevideo',
site: row[1],
address: nil,
location: nil,
external_id: row[0],
sub_program_id: 1,
site_type: row[3],
latitude: row[4],
longitude: row[5],
container_type_id: 12,
}
end
cont2delete = Container.where.not({external_id: externals}).where({state: 'Montevideo'})
file2delete = "#{Rails.root}/public/montevideo-delete.csv"
CSV.open( file2delete, 'w' ) do |writer|
writer << cont2delete.first.attributes.map { |a,v| a }
cont2delete.each do |cont|
writer << cont.attributes.map { |a,v| v }
end
end
=end
  end
  #
  task :custom_containers, [:sub_program_id, :filename, :logo] => [:environment] do |_, args|
    created = 0
    fails = 0
    processed = 0
    file = args[:filename].present? ? args[:filename] : 'tapitas-oportunidades'
    logo = args[:logo].present? ? args[:logo] : false
    sub_program_id = args[:sub_program_id].present? ? args[:sub_program_id] : 982
    ctypes = {}
    ContainerType.all.each {|ct| ctypes[ct.name] = ct.id}
    CSV.foreach("db/data/#{file}.csv", headers: true) do |row|
      processed += 1
      #next if processed == 1
      #puts row
      container = Container.find_or_create_by({
        sub_program_id: sub_program_id,
        latitude: row[1],
        longitude: row[2],
        container_type_id: ctypes[row[8]],
        public_site: 1,
        information: row[0],
        state: row[3],
        location: row[4],
        address: row[5],
        site_type: row[6],
        site: row[7],
      })
      if ( !container.validate! )
        fails += 1
      else
        if logo
          container.schedule_ids = working_days_sched()
          container.custom_icon.attach({io: File.open('app/assets/images/pin_corona.svg'), filename: 'pin_corona'})
          container.custom_icon_active = true
        end
        container.save
        created += 1
      end
    end
    puts "Se procesaron #{(processed)}, se crearon #{created}, fallaron #{fails}"
  end
end
namespace :migration do
  subPprogramMatch = {
    '33822' => 1,
    '33821' => 2,
    '33819'	=> 3,
    '33817'	=> 4,
    '33815'	=> 5,
    '33814'	=> 6,
    '33813'	=> 7,
    '33812'	=> 8,
    '33811'	=> 9,
    '33810'	=> 10,
    '33809'	=> 11,
    '33807'	=> 12,
    '33806'	=> 13,
    '33805'	=> 14
  }
  processed = 0
  created = 0
  fails = 0
  duplicated = 0
  desc 'Importing everything'

  task :programs, [:year] => [:environment] do |_, args|
    require 'csv'

    file = "#{Rails.root}/public/data.csv"


    CSV.open( file, 'w' ) do |writer|
      table = User.all; # ";0" stops output.  Change "User" to any model.
      writer << table.first.attributes.map { |a,v| a }
      table.each do |s|
        writer << s.attributes.map { |a,v| v }
      end
    end

  end
  task :all, [:year] => [:environment] do |_, args|
    Rake::Task['importer:all'].enhance do
      Rake::Task['importer:waste'].invoke
      Rake::Task['importer:programs'].invoke
      Rake::Task['importer:subprograms'].invoke
      Rake::Task['importer:containers'].invoke
    end
  end

  task :programs, [:year] => [:environment] do |_, args|
    programs = []
    CSV.foreach('db/data/programas.csv', headers: true) do |row|
     programs << {
       name: row[1],
       shortname: row[1],
       more_info: row[10],
       reception_conditions: row[5],
       contact: row[6],
       benefits: row[2],
       lifecycle: row[3],
       receives: row[12],
       receives_no: row[13]
     }
    end
    puts programs.inspect
    Program.import programs
  end
  task :subprograms, [:year] => [:environment] do |_, args|

    programs = []
    CSV.foreach('db/data/sub-programas.csv', headers: true) do |row|
      programs << {
        name: row[1],
        program_id: row[7],
        receives: row[8],
        receives_no: row[6]
      }
    end
    SubProgram.import programs
  end
  task :containers, [:year] => [:environment] do |_, args|
    #Update container types
    CSV.foreach('db/data/container_types.csv') do |row|
      if ( ContainerType.where(name: row[0]).empty? )
        ContainerType.create(name: row[0])
      end
    end
    @types_obj = ContainerType.all
    containers = []
    CSV.foreach('db/data/contenedores.csv', headers: true) do |row|
      processed += 1
      @types = @types_obj.dup
      # If no type then report and continue
      if !(@type = @types.select { |typeIn| typeIn[:name] == row[17] }.first )
        fails += 1
        puts "Error in type #{row[17]} en registro #{processed}\n"
        next
      end
      puts "\nTIPO: #{@type.name}\n"
      latlong = row[16].split(', ')
      if ( Container.where({
          sub_program_id: subPprogramMatch[row[14]],
          latitude: latlong[0],
          longitude: latlong[1],
          container_type_id: @type.id,
        }).empty? )
        containers << {
        #Container.create({
          public_site: row[2] == 'Si' ? 1 : 0,
          state: row[5],
          site: row[6],
          address: row[7],
          location: row[11],
          external_id: row[12],
          sub_program_id: subPprogramMatch[row[14]],
          site_type: row[15],
          latitude: latlong[0],
          longitude: latlong[1],
          container_type_id: @type.id,
        }
        created += 1
      else
        duplicated += 1
      end
    end
    #puts containers.inspect
    result = Container.import containers
    fails = result.failed_instances.length()
    #result.failed_instances.each do |failure|
    # handle failure.errors
    #end
    puts "Se procesaron #{processed}, se crearon #{created}, fallaron #{fails} y no se crearon #{duplicated} por estar duplicados"
  end

  task :waste, [:year] => [:environment] do |_, args|
    CSV.foreach('db/data/materiales.csv', headers: true) do |row|
      if ( Material.where(name: row[0]).empty? )
        Material.create(name: row[0], color: row[4])
      end
    end
    #wastes = []
    CSV.foreach('db/data/residuos.csv', headers: true) do |row|
      processed += 1
      if ( waste = Waste.where({
          name: row[1],
          material_id: row[4]
        }).empty? )
        waste = Waste.create({
        #wastes << {
          name: row[1],
          material_id: row[4],
          deposition: row[2],
        })
        if (row[3])
          @subs = SubProgram.where( id: row[3].split(', ').map { |s| s.to_i } )
          waste.sub_programs << @subs
          waste.save
        end
        created += 1
      else
        duplicated += 1
      end
    end
    puts "Se procesaron #{processed}, se crearon #{created}, fallaron #{fails} y no se crearon #{duplicated} por estar duplicados"
  end
end
