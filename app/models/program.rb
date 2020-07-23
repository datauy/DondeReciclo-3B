class Program < ApplicationRecord
  has_one_attached :logo
  has_one_attached :icon
  has_many :supporters

  has_and_belongs_to_many :materials
  has_and_belongs_to_many :wastes

  has_many :location_relations
  has_many :locations, through: :location_relations

  accepts_nested_attributes_for :supporters, :allow_destroy => false

  attr_accessor :logo_url, :materials_arr, :wastes_arr, :supporters_arr, :locations_arr
  #To avoid n+1 query we don't load logos here
  def attributes
    super.merge({
      :logo_url => nil,
      :materials_arr => [],
      :wastes_arr => [],
      :supporters_arr => [],
      :locations_arr => []
    })
  end

end
