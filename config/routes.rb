Rails.application.routes.draw do
  use_doorkeeper do
    # No need to register client application
    skip_controllers :applications, :authorized_applications
  end
  #default_url_options Rails.application.config.action_mailer.default_url_options
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  root to: "admin/dashboard#index"
  devise_for :users, controllers: {
    registrations: 'registrations',
   }, skip: [:sessions, :password]

  get 'api/location4Polygon'
  get 'api/country4Point'
  get 'api/subprogram4location'
  get 'api/zone4point'
  get 'api/materials'
  get 'api/wastes'
  get 'api/container_types'
  get 'api/container/:id', to: 'api#container'
  get 'api/containers'
  get 'api/subprogram_containers'
  get 'api/containers_nearby'
  get 'api/search_predefined'
  get 'api/predefined_searches'
  get 'api/programs'
  get 'api/programs_sum'
  get 'api/news'
  get "api/new/:id", to: "api#new"
  post 'api/contact', to: "utils#contact_email"
  get 'api/user', to: "user_api#me"
  post 'api/user/update', to: 'user_api#update'
  post 'api/user/delete', to: 'user_api#delete'
  post 'api/report', to: "user_api#report"
  post 'api/collect', to: "user_api#collect"
  post 'password/forgot', to: 'utils#forgot'
  post 'password/reset', to: 'utils#reset'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope module: :v2, constraints: ApiConstraint.new(version: 2) do
    get 'api/subprograms4location'
    get 'api/tags_programs'
    get 'api/countries'
    get 'api/dimensions'
    get 'api/search'
    get 'api/containers4materials'
    get 'api/containers_bbox'
    get 'api/containers_bbox4materials'
    get 'api/stats/totals', to: "api_stats#totals"
    get 'api/stats/programs', to: "api_stats#programs"
  end
  scope module: :v1, constraints: ApiConstraint.new(version: 1) do
    get 'api/subprograms4location'
    get 'api/tags_programs', to: 'api#not_implemented'
    get 'api/countries', to: 'api#not_implemented'
    get 'api/dimensions', to: 'api#not_implemented'
    get 'api/search'
    get 'api/containers4materials'
    get 'api/containers_bbox'
    get 'api/containers_bbox4materials'
  end
end
