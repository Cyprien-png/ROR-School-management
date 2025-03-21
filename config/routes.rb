Rails.application.routes.draw do
  resources :grades do
    collection do
      get :deleted
    end
    member do
      patch :undelete
    end
  end
  resources :examinations do
    member do
      get 'students'
    end
    collection do
      get 'available_dates/:lecture_id' => 'examinations#available_dates', as: :available_dates
      get 'deleted', to: 'examinations#deleted', as: :deleted
    end
    member do
      patch 'undelete', to: 'examinations#undelete', as: :undelete
    end
  end
  resources :years do
    collection do
      get :deleted
    end
    member do
      patch :undelete
    end
  end
  resources :lectures
  resources :subjects do
    get 'teachers', on: :member
    collection do
      get 'deleted', to: 'subjects#deleted', as: :deleted
    end
    member do
      patch 'undelete', to: 'subjects#undelete', as: :undelete
    end
  end
  resources :school_classes do
    member do
      post :add_student
      delete :remove_student
      get :year_trimesters
      patch :undelete
    end
    collection do
      get :deleted
    end
  end
  devise_for :people, skip: [:registrations]
  resources :people, only: [:index, :show] do
    collection do
      get 'deleted', to: 'people#deleted', as: :deleted
    end
    member do
      patch 'undelete', to: 'people#undelete', as: :undelete
    end
  end
  resources :students do
    member do
      get :grade_report
    end
  end
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
  root "lectures#index"
end
