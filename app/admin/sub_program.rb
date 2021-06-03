ActiveAdmin.register SubProgram do
  permit_params :name, :reception_conditions, :receives, :receives_no, :program_id, :material_id, material_ids: [], waste_ids: [], location_ids: [], materials_attributes: [:id, :name, :information, :video, :color], reject_if: :all_blank
  before_action :authenticate
  menu if: proc{ current_admin_user.is_admin? }
  config.create_another = true
  #
  controller do
    def authenticate
      if !current_admin_user.is_admin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
    def scoped_collection
      if current_admin_user.is_superadmin?
        resource_class
      else
        resource_class.joins(:program).where("programs.country_id": current_admin_user.country_id)
      end
    end
  end
  form do |f|
    f.inputs do
      f.input :name
      f.input :program_id, :label => 'Programa', :as => :select, :collection => Program.all.map{|s| [s.name, s.id]}
      f.input :reception_conditions
      f.input :receives
      f.input :receives_no
      f.input :material_id, :label => 'Material principal', :as => :select, :collection => Material.all.map{|m| [m.name, m.id]}
      f.input :materials, as: :check_boxes, collection: Material.all
      f.inputs "Residuos" do
        #f.div f.input(:materials, as: :check_boxes), class:"lalala"
        f.input :wastes, as: :check_boxes, nested_set: true, parent: "sub_program[material_ids][]", parent_ids: resource.material_ids, collection: Material.all
        #f.object.materials.build
        #f.has_many :materials, new_record: 'Agregar Material' do |m|
        #  m.input :name
        #  m.input :information
        #  m.input :video
        #  m.input :color
        #end
      end
      f.inputs "Zones" do
        f.input :zones, as: :select, :collection => Zone.all.map{|m| [m.location.name, m.id]}, input_html: { multiple: true }
      end
    end
    f.actions
  end

  index do
    selectable_column
    column :name do |subp|
      link_to subp.name, admin_sub_program_path(subp)
    end
    column :program
    column :city
    column :material
    column :receives
    column :receives_no
    actions
  end
=begin
  controller do
    def scoped_collection
      if current_user.subprogram.nil?
        resource_class
      else
        resource_class.where(collage: current_user.school_type)
      end
    end
  end
=end
end
