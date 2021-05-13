ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation, :role, :country_id

  menu if: proc{ current_admin_user.is_superadmin? }
  before_action :authenticate
  #
  controller do
    def authenticate
      if !current_admin_user.is_superadmin?
        render :file => "public/401.html", :status => :unauthorized
      end
    end
    #Allow blank pass, not to change
    def update
      if params[:admin_user][:password].blank? && params[:admin_user][:password_confirmation].blank?
        params[:admin_user].delete("password")
        params[:admin_user].delete("password_confirmation")
      end
      super
    end
  end
  #
  index do
    selectable_column
    id_column
    column :email
    column :role
    column :country_id
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end
  #
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  #
  form do |f|
    f.inputs do
      f.input :email
      f.input :role
      f.inputs "Country" do
        f.input :country_id, :as => :select, :collection => Country.all.map{|s| [s.name, s.id]}
      end
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
