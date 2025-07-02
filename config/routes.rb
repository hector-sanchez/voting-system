Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes
  post "sessions", to: "sessions#create"    # Login
  delete "sessions", to: "sessions#destroy" # Logout

  # Performer routes
  post "performers", to: "performers#create" # Create performer and vote

  # Vote routes
  post "votes", to: "votes#create" # Cast a vote for an existing performer

  # Defines the root path route ("/")
  root "home#index"
end
