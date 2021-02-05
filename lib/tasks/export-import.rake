namespace :dataexport do
  desc 'Exports all database objects and relations '
  task :containers => :environment do
    filepath = File.join(Rails.root, 'db', 'data', 'containers-export.json')
    puts "- exporting containers into #{filepath}"
    containers = Container.limit(10).order(:id).as_json
    File.open(filepath, 'w') do |f|
      f.write(JSON.pretty_generate(containers))
    end
    puts "- dumped #{containers.size} containers"
  end
end

namespace :dataimport do
  desc 'Imports all objects in directory'
  task :containers => :environment do
    filepath = File.join(Rails.root, 'db', 'data', 'containers-export.json')
    abort "Input file not found: #{filepath}" unless File.exist?(filepath)
    puts "Importing containers"
    containers = JSON.parse(File.read(filepath))
    Container.import containers
    puts "- imported #{containers.size} containers"
  end
end
