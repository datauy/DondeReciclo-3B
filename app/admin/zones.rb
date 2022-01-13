ActiveAdmin.register Zone do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :sub_program_id, :location_id, :is_route, :pick_up_type
  #
  # or
  #
  # permit_params do
  #   permitted = [:sub_program_id, :location_id, :is_route, :pick_up_type]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form :html => { :multipart => true } do |f|
    f.inputs do
      f.input :sub_program_id, :label => 'Subprograma', :as => :searchable_select, :collection => SubProgram.all.map{|s| [s.name, s.id]}
      f.input :location_id, :label => 'Locaion', :as => :searchable_select, :collection => Location.all.map{|s| [s.name, s.id]}
      f.input :is_route
      f.input :pick_up_type
    end
    f.actions
  end
end
