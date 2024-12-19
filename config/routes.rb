require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  resource :cart, only: [:create, :show], controller: 'carts' do
    post 'add_items', action: :add_item
    post 'add_item', action: :add_item
    delete '/:product_id', action: :delete_item
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
