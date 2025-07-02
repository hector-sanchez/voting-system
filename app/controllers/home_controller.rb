class HomeController < ApplicationController
  def index
    if current_user
      # If user is authenticated, redirect to voting results
      redirect_to voting_results_path
    else
      # If user is not authenticated, redirect to sign in
      redirect_to sign_in_path
    end
  end
end
