class HomeController < ApplicationController
  def index
    # For the home page, we'll let the client-side handle the logic
    # The Navigation component will determine if user is authenticated
    # and the page will render appropriate content via JavaScript
  end
end
