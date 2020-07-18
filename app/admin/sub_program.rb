ActiveAdmin.register SubProgram do
  permit_params :name, :reception_conditions, :receives, :receives_no, :program_id, :material_id, material_ids: [], waste_ids: [], materials_attributes: [:id, :name, :information, :video, :color], reject_if: :all_blank
  config.create_another = true

  form do |f|
    f.inputs do
      f.input :name
      f.input :program_id, :label => 'Programa', :as => :select, :collection => Program.all.map{|s| [s.name, s.id]}
      f.input :reception_conditions
      f.input :receives
      f.input :receives_no
      f.input :material_id, :label => 'Material principal', :as => :select, :collection => Material.all.map{|m| [m.name, m.id]}
      f.inputs "Materiales" do
        f.input :materials, as: :check_boxes
        #f.object.materials.build
        #f.has_many :materials, new_record: 'Agregar Material' do |m|
        #  m.input :name
        #  m.input :information
        #  m.input :video
        #  m.input :color
        #end
      end
      f.inputs "Wastes" do
        f.input :wastes, as: :check_boxes
      end
    end
    f.actions
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
