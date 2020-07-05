class ApiController < ApplicationController
  #
  def containers_nearby
    @cont = Container
      .near([params[:lat], params[:lon]])
      .includes( :sub_program )
      .limit(20)
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
  #Se tuvo que hacer la carga por partes dado que la consulta de near no responde en caso que el where opere sobre toda la consulta
  #Por o que se hace la primer carga de subprogramas eager y las consultas de materiales lazy
  def containers4materials
    if (params[:materials])
      materials_by = params[:materials].split(',')
    else
      return self.containers_nearby
    end
    @cont = Container
      .includes( :sub_program )
      .near( [params[:lat], params[:lon]] )
      .joins( sub_program: [:materials] )
      .where( :"materials_sub_programs.material_id" => materials_by )
      .limit(20)

    render json: format_pins(@cont)
  end
  #
  def container_types
    render json: ContainerType.all.map{|cont| [cont.id, {
      id: cont.id,
      name: cont.name,
      class: cont.name.downcase.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').gsub(/\s/,'-'),
      icon: cont.icon.attached? ? url_for(cont.icon) : ''
    }]}.to_h
  end
  #
  def materials
    render json: Material.all.map{|mat| [mat.id, {
      id: mat.id,
      name: mat.name,
      class: mat.name.downcase.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').gsub(/\s/,'-'),
      color: mat.color,
      icon: mat.icon.attached? ? url_for(mat.icon) : ''
    }]}.to_h
  end
  #
  def search
    if ( params[:q].length > 2 )
      @str = params[:q].downcase
      render json: format_search(
        Material.search(@str)+
        Waste.search(@str)+
        Product.search(@str)
      ).sort_by! {|r| r[:name]}
    else
      render json: {error: 'Insuficient parameter length, at least 3 charachters are required'}
    end
  end
  #
  def search_predefined
    country = 1 #load Uruguay/first by default
    country = params[:country] if params[:country]
    psearch = PredefinedSearch
      .where( :country_id => country )
      .first
    render json: format_search(
      Material
       .joins(:predefined_searches)
       .where( :"predefined_searches.id" => psearch.id ) +
      Waste
       .joins(:predefined_searches)
       .where( :"predefined_searches.id" => psearch.id )
    )
  end
  def programs
    # TODO: Fijarse cómo agregar un campo al objeto sin tener que mapear todo de nuevo :(
    res = []
    Program.all.
      includes(:materials).
      includes(:supporters).
      includes(:wastes).
      includes(:locations).
      with_attached_logo.
      each do |prog|
        prog.logo_url = prog.logo.attached? ? url_for(prog.logo) : ""
        prog.materials_arr = prog.materials.map{ |mat| mat.id }
        prog.wastes_arr = prog.wastes.map{ |mat| mat.id }
        prog.locations_arr = prog.locations.map{ |loc| loc.name }
        prog.supporters_arr = prog.supporters.map{ |sup| {
          :name => sup.name,
          :url => sup.url
          }
        }
        res << prog
      end
    render json: res
  end
  # TODO: Pasar los subprogramas en la carga inicial ya que se repiten muchos datos, acá pasar sólo el subId
  private
  def format_pins(objs)
    return objs.map{|cont| ({
      id: cont.id,
      type_id: cont.container_type_id,
      program_id: cont.sub_program.program_id,
      latitude: cont.latitude,
      longitude: cont.longitude,
      program: cont.sub_program.program.name,
      subprogram: cont.sub_program.name,
      location: cont.site,
      address: cont.address,
      public: cont.public_site,
      materials: cont.sub_program.materials.ids,
      wastes: cont.sub_program.wastes.ids,
      main_material: cont.sub_program.material.id,
      photos: [cont.photos.attached? ? url_for(cont.photos) : ''],  #.map {|ph| url_for(ph) } : '',
      receives_no: cont.sub_program.receives_no
    }) }
  end
  def format_search(objs)
    res = []
    objs.each do |mat|
      oa = { id: mat.id, name: mat.name, deposition: nil, type: mat.class.name, material_id: mat.id }
      if mat.class.name == 'Waste'
        oa[:material_id] = mat.material.nil? ? 0 : mat.material.id
        oa[:deposition] = mat.deposition
      elsif mat.class.name == 'Product'
        oa[:material_id] = mat.material.nil? ? 0 : mat.material.id
      end
      res << oa
    end
    return res
  end
end
