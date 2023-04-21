
#
namespace :utils do
  task :run_database_updates, [:filename] => [:environment] do |_, args|
    #change locations
    #assign_country
    #Update users
    User.where(country_id: 1, state: ['Valle del Cauca', 'Bolívar', 'Atlántico', 'Cundinamarca', 'Meta', 'Antioquia', 'Boyacá', 'Córdoba', 'Bogotá', 'Magdalena', 'La Guajira']).
      update(country_id: 2)
    User.where(country_id: 1, state: '').
    where.not(neighborhood: ["1ro de mayo", "Malvin Norte","prado", "villa Dolores ", "Buceo", "la cooperativa ", "buceo", "Ciudad Vieja", "montevideo", "cetro", "casavalle", "shangrila", "Las Acacias","union", "popcitos", "progreso", "Solymar norte", "centro", "Shangrilá", "Aguada","El Pinar ", "Carassco", "SOLYMAR", "Solymar", "Pocitos ", "La floresta", "punta Carretas", "chuy", "Montevideo ", "Larrañaga",  "Trouville", "San José", "La Blanqueada",  "Villa Dolores", "Aguada ","Manga",  "Ciudad de la Costa", "Lezica - Montevideo", "lavalleja", "Colon", "Parque Rodó", "Ripoll", "Nuevo París", "parque miramar", "Montevideo, Punta Gorda", "Bella Vista", "Maldonado", "carrasco ", "centro ", "pocitos", "Carrasco", "Montevideo", "puerto", "Avenida Antonio Raimondi", "san isidro", "Centro", "Pocitos Nuevo", "parque batlle ", "Monte Castro", "El Pinar", "Peñarol ", "salinas", "Balneario Buenos Aires", "Villa Biarritz", "Villa Española", "Prado ", "belvedere", "parque del plata", "punta del este", "Villa del prado", "la blanqueada", "parque rodó ", "Cordon", "Pocitos", "punta gorda", "carrasco", "manantiales"]).
    update(country_id: 2)
  end
  task :assign_country, [:filename] => [:environment] do |_, args|
    uy = Location.where(name: 'Uruguay').first
    uy.update(loc_type: 'country')
    puts "updating loc_type for UY states"
    Location.where(country_id: 1).where(loc_type: nil).update(loc_type: 'state')
    Location.where.not(geometry: nil).each do |loc|
      puts "processing location #{loc.name}\n"
      if loc.geometry.intersects?(uy.geometry)
        puts "Está en UY #{loc.name}"
        loc.update(country_id: 1)
      else
        puts "No está en UY #{loc.name}"
      end
    end
  end
  #
  task :clean_locations,  [:filename] => [:environment] do |_, args|
    #Params
    file = args[:filename].present? ? args[:filename] : 'motorecicladores-CO.geojson'
    procesed = []
    p = 0
    Location.where(country_id: 2).each do |loc|
      p += 1
      break if p == 6
      #current_loc = loc
      next if procesed.include? loc.id
      locs = Location.where("lower(name) = :value and country_id = 2", value: "#{loc.name.strip.downcase}")
      if locs.count > 1
        puts "Processing #{loc.name.strip.downcase} with main id #{loc.id}...\n"
        procesed += locs.ids
        #get location with geometries
        glocs = locs.where.not(geometry: nil)
        if glocs.length > 1
          puts "GEOM CONFLICT with #{locs.ids.inspect}\n"
          next
        elsif glocs.length == 0
          main_loc = loc
        else
          main_loc = glocs.first
        end
        other_loc = locs.where.not(id: main_loc.id)
        #merege loc_type
        other_loc.each do |oloc|
          if oloc.loc_type.present?
            if main_loc.loc_type.nil?
              main_loc.loc_type = oloc.loc_type
            else
              puts "LOC TYPE CONFLICT with #{oloc.id} and  #{main_loc.id}\n"
              next
            end
          end
          if oloc.parent_location_id.present?
            if main_loc.parent_location_id.nil?
              main_loc.parent_location_id = oloc.parent_location_id
            else
              puts "LOC TYPE CONFLICT with #{oloc.id} and  #{main_loc.id}\n"
              next
            end
          end
          puts "Changing relations for #{oloc.id}\n"
          oloc.location_relations.update(location_id: main_loc.id)
          oloc.zones.update(location_id: main_loc.id)
          #oloc.destroy()
        end
      else
        puts "Skipped #{loc.name.strip.downcase}...\n"
      end
    end
  end
  task :assign_states, [:filename] => [:environment] do |_, args|
    p = 0
    #Containers out of scope
    #Container.includes(sub_program: :program).where('programs.country_id': country).where.not("ST_within(ST_Point( containers.longitude, containers.latitude), (select geometry from locations where id = ?))", uy.id).group(:'programs.name').count
    [1].each do |cid|
      states = Location.where(country_id: cid, loc_type: 'state')
      other_locs = Location.where(country_id: cid).where.not(loc_type: 'country').where.not(loc_type: 'state')
      other_locs.each do |loc|
        p += 1
        break if p == 6
        puts "Procesing #{loc.id} - #{loc.loc_type} - #{loc.name}"
        states.each do |state|
          if loc.geometry.intersects?(state.geometry)
            puts "Found in state #{state.name}"
            loc.update(parent_location_id: state.id)
            break
          end
        end
      end
    end
  end
end


        #Get location associations
