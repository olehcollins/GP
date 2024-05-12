Rails.application.routes.draw do
  devise_for :users
  root to: "home#home"
  get 'browse', to: 'home#index', as: 'browse_cons'

  get 'dr_app', to: 'appointments#index', as: 'dr_appointments'
  get 'pt_app', to: 'appointments#index', as: 'pt_appointments'
  get 'inbox', to: 'appointments#inbox', as: 'messages'

  get "up" => "rails/health#show", as: :rails_health_check

  resources :appointments, only: [:destroy, :update, :index] do
    member do
      post 'approve'
      post 'cancel'
      post 'deny'
    end
  end
  # Consultations
    resources :consultations do
      resources :appointments, only: [:new, :create]
    end

end
