Rails.application.routes.draw do
  resources :years
  resources :lectures
  resources :subjects do
    get 'teachers', on: :member
  end
  resources :school_classes do
    member do
      post :add_student
      delete :remove_student
      get :year_trimesters
    end
  end
  devise_for :people, skip: [:registrations]
  resources :people, only: [:index, :show]
  resources :students
  resources :teachers do
    get 'school_classes', on: :member
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "people#index"
end
