class ApiController < ApplicationController
  def containers_nearby
    @cont = Container
      .near([params[:lat], params[:lon]], 5)
      .includes( sub_program:[:program, :materials] )
      .limit(30)
      #.pluck(:'materials.name', :container_types.icon).where()
    render json: format_pins(@cont)
  end
  def containers
    @cont = Container
      .where( sub_program_id: params[:sub_id] )
      .includes( sub_program:[:program, :materials, :wastes] )
      .limit(5)
      #.pluck(:'materials.name', :container_types.icon).where()
    render json: format_pins(@cont)
  end
  def container_types
    render json: ContainerType.all.map{|cont| ({ id: cont.id, name: cont.name, icon: url_for(cont.icon) })}
  end
  def materials
    render json: Materials.all.map{|mat| ({ id: mat.id, name: mat.name, icon: url_for(cont.image) })}
  end

  private
  def format_pins(objs)
    return objs.map{|cont| ({
      id: cont.id,
      program: cont.sub_program.program.name,
      program_id: cont.sub_program.program_id,
      latitude: cont.latitude,
      longitude: cont.longitude,
      location: cont.site,
      public: cont.public_site,
      type_id: cont.container_type_id,
      materials: cont.sub_program.materials.ids,
    }) }
  end
end
