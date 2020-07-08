Rails.application.routes.draw do
  #default_url_options Rails.application.config.action_mailer.default_url_options
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  root to: "static_pages#index"
  devise_for :users

  get 'api/materials'
  get 'api/container_types'
  get 'api/containers'
  get 'api/containers_bbox'
  get 'api/containers_nearby'
  get 'api/search'
  get 'api/search_predefined'
  get 'api/containers4materials'
  get 'api/programs'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
