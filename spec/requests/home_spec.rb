require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /index" do
    it "renders a successfully" do
      get root_path
      expect(response).to be_successful
      expect(response.body).to include('Hello, world!')
    end
  end
end
