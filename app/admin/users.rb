ActiveAdmin.register User do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :email, :name, :sex, :state, :neighborhood, :age, :country_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :name, :sex, :state, :neighborhood, :age, :country_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  menu if: proc{ current_admin_user.is_superadmin? }
  before_action :authenticate
  #
  controller do
    def authenticate
      if !current_admin_user.is_superadmin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
  end
  index do
    selectable_column
    id_column
    column :name
    column :sex
    column :email
    column :country
    column :state
    column :neighborhood    
    actions
  end
end
