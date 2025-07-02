require 'rails_helper'

RSpec.describe VotingResultsController, type: :request do
  let(:user) { create(:user) }
  let(:jwt_token) { JWT.encode(user.generate_token_payload, Rails.application.secret_key_base) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  before do
    # Create some test data
    @performer1 = create(:performer, name: 'Performer One')
    @performer2 = create(:performer, name: 'Performer Two')
    @performer3 = create(:performer, name: 'Performer Three')

    # Create users and votes
    @user1 = create(:user, email: 'user1@test.com')
    @user2 = create(:user, email: 'user2@test.com')
    @user3 = create(:user, email: 'user3@test.com')

    # Create votes: performer1 gets 2 votes, performer2 gets 1 vote, performer3 gets 0 votes
    create(:vote, user: @user1, performer: @performer1)
    create(:vote, user: @user2, performer: @performer1)
    create(:vote, user: @user3, performer: @performer2)
  end

  describe 'GET /voting_results' do
    it 'returns all performers with their vote counts' do
      get '/voting_results', as: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response['total_votes']).to eq(3)
      expect(json_response['results']).to be_an(Array)
      expect(json_response['results'].length).to eq(3)

      # Check that results are ordered by vote count (descending)
      results = json_response['results']
      expect(results[0]['performer']['name']).to eq('Performer One')
      expect(results[0]['vote_count']).to eq(2)

      expect(results[1]['performer']['name']).to eq('Performer Two')
      expect(results[1]['vote_count']).to eq(1)

      expect(results[2]['performer']['name']).to eq('Performer Three')
      expect(results[2]['vote_count']).to eq(0)
    end
  end

  describe 'when no votes exist' do
    before do
      Vote.destroy_all
    end

    it 'handles empty voting results gracefully' do
      get '/voting_results', as: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response['total_votes']).to eq(0)
      expect(json_response['results']).to be_an(Array)
      expect(json_response['results'].length).to eq(3)

      # All performers should have 0 votes
      json_response['results'].each do |result|
        expect(result['vote_count']).to eq(0)
      end
    end
  end
end
