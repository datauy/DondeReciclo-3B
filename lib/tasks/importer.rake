namespace :importer_col do
  def all_day_sched
    ids = []
    for i in 1..7
      sched = {
        weekday: i,
        start: '00:00',
        end: '23:59'
      }
      schedule = Schedule.find_or_create_by(sched)
      ids << schedule.id
    end
    return ids
  end
  task :containers, [:file] => :environment do |_, args|
    puts "Empieza importación de puntos"
    file = args[:file].present? ? args[:file] : 'contenedores_colombia.geojson'
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    f = RGeo::GeoJSON.decode(File.read( "db/data/#{file}" ))
    i = 0
    allDayIds = all_day_sched();
    f.each do |feature|
      i = i + 1
      #if i < 2150
      #  next
      #end
      puts "Contenedor #{i}\n"
      sub_prog = {
        program_id: 1,
        city:  feature.properties["Ciudad"],
        email: feature.properties["Correo"],
        name: feature.properties["Responsabl"],
      }
      sub_program = SubProgram.find_or_create_by(sub_prog)
      if !sub_program.validate!
        puts "ERROR Subprogram: #{sub_program.errors.full_messages}\n exiting..."
        next
      end
      #Los materiales se asocian manualmente a los subprogramas
      container = {
        site: feature.properties["Nombre_lug"].present? ? feature.properties["Nombre_lug"] : '',
        latlon: feature.geometry,
        latitude: feature.geometry.coordinates[1],
        longitude: feature.geometry.coordinates[0],
        location:  feature.properties["Ciudad"],
        address: feature.properties["Dirección"],
        public_site: 1,
        sub_program_id: sub_program.id,
        site_type: feature.properties["Nombre_lug"] == "Espacio Público" ? "En vía pública" : "",
        container_type_id: 3,
      }
      if feature.properties["Id"].present?
        container[:external_id] = feature.properties["Id"]
      end
      update_sub = false
      if feature.properties["Dias_recol"].present? && feature.properties['Horario_at'].present?
        sub_program.receives = "#{feature.properties['Dias_recol']}: #{feature.properties['Horario_at']}"
        update_sub = true
      end
      if feature.properties['Condicione'].present?
        sub_program.reception_conditions = feature.properties['Condicione']
        update_sub = true
      end
      if update_sub
        sub_program.save
      end
      container = Container.find_or_create_by(container)
      if !container.validate!
        puts "ERROR: #{container.errors.full_messages}\n exiting..."
        next
      end
      #Get schedules
      scheds = []
      if feature.properties["Horario_at"]  == 'Permanente' && feature.properties["Funcionami"] == 'Permanente'
        scheds = allDayIds
        puts "Asignado automáticamente el calendario para todos los días\n"
      else
        puts "No se puede asignar automáticamente el calendario: #{feature.properties["Id"]}\n"
      end
      container.schedule_ids = scheds
      container.save
    end
    puts "\n\nSe importaron #{i} contenedores_colombia\n"
  end
  task :zones, [:file, :pick_up_type] => :environment do |_, args|
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    file = args[:file].present? ? args[:file] : 'cobertura-Colombia-4326.geojson'
    f = RGeo::GeoJSON.decode(File.read("db/data/#{file}"))
    f.each do |feature|
      loc = {
        name: feature.properties["Cobertura"],
        geometry: feature.geometry
      }
      loc = Location.find_or_create_by(loc)
      sub_prog = {
        program_id: 1,
        city:  feature.properties["Ciudad"],
        address: feature.properties["Dirección"],
        email: feature.properties["Correo"],
        phone: feature.properties["Teléfono"],
        name: feature.properties["Organizaci"],
        full_name: feature.properties["OR_"].present? ? feature.properties["OR_"] : feature.properties["Organizaci"]
      }
      sub_program = SubProgram.find_or_create_by(sub_prog)
      zone_data = {
        location: loc,
        sub_program: sub_program,
        is_route: FALSE,
        pick_up_type: args[:pick_up_type].present? ? args[:pick_up_type] : 1
      }
      zone = Zone.find_or_create_by(zone_data)
      if !zone.validate!
        puts "ERROR: #{zone.errors.full_messages}\n next..."
        next
      end
    end
  end
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
  task :routes, [:filename, :pick_up_type]  => :environment do |_, args|
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    #factory = RGeo::Geographic.spherical_factory(:srid => 4326)
    #fid = 1
    #for fid in [1,2,3]
    filename = args[:filename].present? ? args[:filename] : 'costa'
      f = RGeo::GeoJSON.decode(File.read("db/data/microrutas-#{filename}.geojson"))#, json_parser: :json, geo_factory: RGeo::Geographic.simple_mercator_factory)
      mainMaterial = Material.find_by({:name => 'Materiales reciclables'})
      f.each do |feature|
        loc = {
          name: feature.properties["Cobertura"],
          geometry: feature.geometry#factory.multi_polygon([feature.geometry])
        }
        #materialId materiales reciclables
        loc = Location.find_or_create_by(loc)
        sub_prog = {
          program_id: 19,
          city:  feature.properties["Ciudad"],
          address: feature.properties["Dirección"],
          email: feature.properties["Correo"],
          phone: feature.properties["Telefono"],
          name: feature.properties["Organizaci"],
          full_name: feature.properties["OR_"].present? ? feature.properties["OR_"] : feature.properties["Organizaci"],
          material: mainMaterial,
        }
        puts sub_prog.inspect
        sub_program = SubProgram.find_or_create_by(sub_prog)
        if !sub_program.validate!
          puts "ERROR: #{sub_program.errors.full_messages}\n next..."
          next
        end
        zone_data = {
          location: loc,
          sub_program: sub_program,
          is_route: TRUE,
          pick_up_type: args[:pick_up_type].present? ? args[:pick_up_type] : 2
        }
        zone = Zone.find_or_create_by(zone_data)
        if !zone.validate!
          puts "ERROR: #{zone.errors.full_messages}\n next..."
          next
        end
        # TODO: Agregar calendarios
        if args[:update].present? && args[:update]
          sub_program.receives = "#{sub_program.receives.present? ? sub_program.receives+' |' : ''} #{feature.properties["Cobertura"]}: #{feature.properties["Frecuencia"]} - #{feature.properties["Hora_inici"]} a #{feature.properties["Hora_fin"]}"
          #Materiales: Papel y cartón, vidrio y plástico... residuos lata de aluminio
          #sub_program.material_ids = [2,3,4]
          #sub_program.waste_ids = 101
          sub_program.save
        end
      end
    #end
  end
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
