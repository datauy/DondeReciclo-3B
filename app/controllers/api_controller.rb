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
    render json: ContainerType.all.map{|cont| ({ id: cont.id, name: cont.name, icon: cont.icon.attached? ? url_for(cont.icon) : '' })}
  end
  def materials
    render json: Materials.all.map{|mat| ({ id: mat.id, name: mat.name, icon: cont.image.attached? ? url_for(cont.image) : '' })}
  end
  def search
    if ( params[:q].length > 2 )
      @str = params[:q].downcase
      render json:
        (Material.search(@str).map{|mat| ({ id: mat.id, name: mat.name, deposition: '', type: 'Material', material_id: mat.id })} +
        Waste.search(@str).map{|mat| ({ id: mat.id, name: mat.name, deposition: mat.deposition, type: 'Waste', material_id: mat.material.nil? ? 0 : mat.material.id })} +
        Product.search(@str).map{|mat| ({ id: mat.id, name: mat.name, deposition: '', type: 'Product', material_id: mat.material.nil? ? 0 : mat.material.id })}).sort_by! {|r| r[:name]}
    else
      render json: {error: 'Insuficient parameter length, at least 3 charachters are required'}
    end
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
