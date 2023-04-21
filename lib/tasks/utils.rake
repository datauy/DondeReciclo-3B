
#
namespace :utils do
  task :stats_database_updates, [:filename] => [:environment] do |_, args|
    #change locations
    #assign_country
    #Update users
    User.where(country_id: 1, state: ['Valle del Cauca', 'Bolívar', 'Atlántico', 'Cundinamarca', 'Meta', 'Antioquia', 'Boyacá', 'Córdoba', 'Bogotá', 'Magdalena', 'La Guajira']).
      update(country_id: 2)
    User.where(country_id: 1, state: '').
    where.not(neighborhood: ["1ro de mayo", "Malvin Norte","prado", "villa Dolores ", "Buceo", "la cooperativa ", "buceo", "Ciudad Vieja", "montevideo", "cetro", "casavalle", "shangrila", "Las Acacias","union", "popcitos", "progreso", "Solymar norte", "centro", "Shangrilá", "Aguada","El Pinar ", "Carassco", "SOLYMAR", "Solymar", "Pocitos ", "La floresta", "punta Carretas", "chuy", "Montevideo ", "Larrañaga",  "Trouville", "San José", "La Blanqueada",  "Villa Dolores", "Aguada ","Manga",  "Ciudad de la Costa", "Lezica - Montevideo", "lavalleja", "Colon", "Parque Rodó", "Ripoll", "Nuevo París", "parque miramar", "Montevideo, Punta Gorda", "Bella Vista", "Maldonado", "carrasco ", "centro ", "pocitos", "Carrasco", "Montevideo", "puerto", "Avenida Antonio Raimondi", "san isidro", "Centro", "Pocitos Nuevo", "parque batlle ", "Monte Castro", "El Pinar", "Peñarol ", "salinas", "Balneario Buenos Aires", "Villa Biarritz", "Villa Española", "Prado ", "belvedere", "parque del plata", "punta del este", "Villa del prado", "la blanqueada", "parque rodó ", "Cordon", "Pocitos", "punta gorda", "carrasco", "manantiales"]).
    update(country_id: 2)
    col = Country.find(2)
  	Location.find_or_create_by({name: 'Colombia', loc_type: "country", geometry: col.geometry, country_id: 2})
  	Location.where(name: 'Uruguay').first.update(loc_type: 'country')
    puts "updating loc_type for UY states"
  	Location.where(country_id: 1).where(loc_type: nil).update(loc_type: 'state')
  end
  #
  task :assign_country, [:filename] => [:environment] do |_, args|
    Location.where.not(geometry: nil).each do |loc|
      puts "processing location #{loc.name}\n"
      country_id = Location.
      where( loc_type: 'country' ).
      where( "ST_Intersects( geometry, (select geometry from locations where id = :loc) )", loc: loc.id).
      pluck(:country_id).first
      if country_id.present?
        puts "Está en #{country_id} -> #{loc.name}"
        loc.update(country_id: country_id)
      else
        puts "No está en #{country_id} -> #{loc.name}"
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
    [1, 2].each do |cid|
      other_locs = Location.
      where(country_id: cid).
      where.not(loc_type: ['country', 'state'], geometry: nil).
      or( Location.where(country_id: cid, loc_type: nil).where.not(geometry: nil) )
      other_locs.each do |loc|
        if loc.loc_type.nil?
          p "Updating loc_type"
          loc.update(loc_type: 'area')
        end
        if loc.parent_location_id.nil?
          p "Processing parent location: #{loc.id} - #{loc.loc_type} - #{loc.name}"
          state_id = Location.
          where( loc_type: 'state', country_id: cid ).
          where( "ST_Intersects( st_buffer(geometry, -0.001), (select geometry from locations where id = :loc) )", loc: loc.id).
          pluck(:id)
          if ( state_id.present? )
            p "Updating Parent location #{state_id}"
            loc.update(parent_location_id: state_id.first)
          else
            p "No state found"
          end
        else
          p "Parent location already set: #{loc.id} - #{loc.loc_type} - #{loc.name}"
        end
      end
    end
  end
end


        #Get location associations
