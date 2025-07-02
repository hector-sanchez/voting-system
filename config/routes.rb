Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes
  get "sign_in", to: "sessions#new"        # Sign in page
  post "sessions", to: "sessions#create"    # Login
  delete "sessions", to: "sessions#destroy" # Logout

  # Performer routes
  get "performers", to: "performers#index"   # List all performers
  post "performers", to: "performers#create" # Create performer and vote

  # Vote routes
  get "vote", to: "votes#new"           # Voting page
  post "votes", to: "votes#create"      # Cast a vote for an existing performer

  # Voting results routes
  get "voting_results", to: "voting_results#index"      # List all performers with vote counts

  # Defines the root path route ("/")
  root "voting_results#index"
end
