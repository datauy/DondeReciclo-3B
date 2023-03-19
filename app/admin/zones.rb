ActiveAdmin.register Zone do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :sub_program_id, :location_id, :is_route, :pick_up_type, :route_id, :custom_active, :color, :icon_start, :icon_end, schedule_ids:[], schedules_attributes:[:id, :weekday, :start, :end, :desc, :closed]
  #
  # or
  #
  # permit_params do
  #   permitted = [:sub_program_id, :location_id, :is_route, :pick_up_type]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  filter :id
  filter :sub_program_id, :label => 'Subprograma', :as => :searchable_select, :collection => SubProgram.all.map{|s| [s.name, s.id]}
  filter :location_id, :label => 'Location', :as => :searchable_select, :collection => Location.all.map{|s| [s.name, s.id]}
  filter :is_route


  form :html => { :multipart => true } do |f|
    f.inputs do
      f.input :sub_program_id, :label => 'Subprograma', :as => :searchable_select, :collection => SubProgram.all.map{|s| [s.name, s.id]}
      f.input :location_id, :label => 'Location', :as => :searchable_select, :collection => Location.all.map{|s| [s.name, s.id]}
      f.input :route_id, :label => 'Route', :as => :searchable_select, :collection => Route.all.map{|s| [s.name, s.id]}
      f.input :is_route
      f.input :pick_up_type
      f.input :schedules, as: :select, collection: Schedule.all.map{|s| [s.desc, s.id]}
      f.has_many :schedules do |sched|
        sched.inputs
      end
      f.input :custom_active
      f.input :color
      f.input :icon_start, as: :file
      f.input :icon_end, as: :file
      if f.object.icon_start.attached?
        span image_tag(f.object.icon_start)
          a "Borrar", src: delete_image_admin_container_path(image_id: f.object.icon_start.id), method: :delete, "data-confirm": "Confirme que desea eliminarla"
      end
      if f.object.icon_end.attached?
        span image_tag(f.object.icon_end)
          a "Borrar", src: delete_image_admin_container_path(image_id: f.object.icon_end.id), method: :delete, "data-confirm": "Confirme que desea eliminarla"
      end
    end
    f.actions
  end

  batch_action :add_schedule, form: -> {
    { schedule: Schedule.all.map{|sched| [sched.formated_str, sched.id]} }
  } do |ids, inputs|
    # inputs is a hash of all the form fields you requested
    redirect_to collection_path, notice: [ids, inputs].to_s
  end
end
