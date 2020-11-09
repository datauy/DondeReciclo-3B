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
  task :containers  => :environment do
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    f = RGeo::GeoJSON.decode(File.read('db/data/contenedores_colombia.geojson'))
    i = 0
    allDayIds = all_day_sched();
    f.each do |feature|
      i = i + 1
      if i < 2150
        next
      end
      puts "Contenedor #{i}\n"
      sub_prog = {
        program_id: 17,
        city:  feature.properties["Ciudad"],
        email: feature.properties["Correo"],
        name: feature.properties["Responsabl"],
      }
      sub_program = SubProgram.find_or_create_by(sub_prog)
      #Los materiales se asocian manualmente a los subprogramas
      container = {
        site: feature.properties["Nombre_lug"],
        latlon: feature.geometry,
        latitude: feature.geometry.coordinates[1],
        longitude: feature.geometry.coordinates[0],
        location:  feature.properties["Ciudad"],
        address: feature.properties["Dirección"],
        public_site: 1,
        external_id: feature.properties["Id"],
        sub_program_id: sub_program.id,
        site_type: feature.properties["Nombre_lug"] == "Espacio Público" ? "En vía pública" : "Supermercado",
        container_type_id: 3,
      }
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
  task :zones  => :environment do
    #@geo_factory = RGeo::Geographic.spherical_factory(srid: 4326)
    f = RGeo::GeoJSON.decode(File.read('db/data/cobertura-Colombia-4326.geojson'))
    f.each do |feature|
      loc = {
        name: feature.properties["Cobertura"],
        geometry: feature.geometry
      }
      loc = Location.find_or_create_by(loc)
      sub_prog = {
        program_id: 17,
        city:  feature.properties["Ciudad"],
        address: feature.properties["Dirección"],
        email: feature.properties["Correo"],
        phone: feature.properties["Teléfono"],
        name: feature.properties["Organizaci"],
        full_name: feature.properties["OR_"]
      }
      sub_program = SubProgram.find_or_create_by(sub_prog)
      if !sub_program.location_ids.include?(loc.id)
        sub_program.locations << loc
      end
      sub_program.save
    end
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
