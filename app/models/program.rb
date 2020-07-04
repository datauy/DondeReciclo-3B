class Program < ApplicationRecord
  has_one_attached :logo
  has_many :supporters

  has_and_belongs_to_many :materials
  has_and_belongs_to_many :wastes

  attr_accessor :logo_url
  attr_accessor :materials_arr
  attr_accessor :wastes_arr
  #To avoid n+1 query we don't load logos here
  def attributes
    super.merge({
      'logo_url' => nil,
      'materials_arr' => [],
      'wastes_arr' => []
      })
  end

end
