namespace :importer do
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
