Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: "static_pages#index"
  devise_for :users

  get 'api/container_types'
  get 'api/pins'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
