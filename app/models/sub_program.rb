class SubProgram < ApplicationRecord
  belongs_to :program
  belongs_to :material
  has_many :containers

  has_and_belongs_to_many :materials #, primary_key: [:material_id, :sub_program_id]
  accepts_nested_attributes_for :materials, :allow_destroy => false

  has_and_belongs_to_many :wastes
  accepts_nested_attributes_for :wastes, :allow_destroy => false

  has_many :zones
  has_many :locations, through: :zones

  class HABTM_Materials
    self.primary_key = :material_id
  end
  #
  def add_wastes_or_materials(wastes_names, update)
    errors = self.add_wastes(wastes_names, update)
    errors += self.add_materials(wastes_names, update)
  end
  #
  def add_wastes(wastes_names, update)
    log = []
    wastes_names.each do |waste_name|
      waste = Waste.search_name(waste_name).first
      if waste.present?
        if !self.wastes.include? waste
          self.wastes << waste
          log << "Residuo AGREGADO: #{waste_name}"
        end
      else
        log << "Residuo NO ENCONTRADO: #{waste_name}"
      end
    end
    if update
      self.save
    end
    return log
  end
  #
  def add_materials(wastes_names, update)
    log = []
    wastes_names.each do |waste_name|
      material = Material.search_name(waste_name).first
      if material.present?
        if !self.materials.include? material
          self.materials << material
          log << "Material AGREGADO: #{waste_name}"
        end
      else
        log << "Material NO ENCONTRADO: #{waste_name}"
      end
    end
    #Add only new wastes
    if update
      self.save
    end
    return log
  end

end
