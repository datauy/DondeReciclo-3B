class ApiController < ApplicationController
  def pins
    @cont = Container
      .includes( :sub_program )
      #.pluck(:'materials.name', :container_types.icon).where()
    render json: @cont.map{|cont| ({
      subprogram: cont.sub_program.name,
      subprogram_id: cont.sub_program_id,
      lat: cont.lat,
      long: cont.long,
      location: cont.site,
      public: cont.public_site,
      type_id: cont.container_type_id,
      materials: cont.sub_program.materials,
    }) }
  end
  def container_types
    render json: ContainerType.all.map{|cont| ({ id: cont.id, name: cont.name, icon: url_for(cont.icon) })}
  end
end
