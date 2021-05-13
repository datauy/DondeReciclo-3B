class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum role: [
    'super_admin',
    'admin',
    'responsible',
    'comunication',
  ]
  has_one :country
  def is_admin?
    ['admin', 'super_admin'].include?(self.role)
  end
  def is_superadmin?
    ['super_admin'].include?(self.role)
  end
end
