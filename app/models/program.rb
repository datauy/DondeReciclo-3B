class Program < ApplicationRecord
  has_one_attached :logo
  has_many :supporters

  has_and_belongs_to_many :materials
  accepts_nested_attributes_for :materials, :allow_destroy => false

  attr_accessor :logo_url
  attr_accessor :materials_arr
  #To avoid n+1 query we don't load logos here
  def attributes
    super.merge({
      'logo_url' => nil,
      'materials_arr' => []
      })
  end

end
