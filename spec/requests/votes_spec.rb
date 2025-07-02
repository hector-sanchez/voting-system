require 'rails_helper'

RSpec.describe 'Votes', type: :request do
  describe 'POST /votes' do
    let!(:user) { create(:user) }
    let!(:performer) { create(:performer) }
    let(:token) { JWT.encode(user.generate_token_payload, Rails.application.secret_key_base, 'HS256') }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    context 'with valid parameters and authenticated user' do
      let(:valid_params) do
        {
          vote: {
            performer_id: performer.id
          }
        }
      end

      it 'creates a vote successfully' do
        expect {
          post '/votes', params: valid_params, headers: headers, as: :json
        }.to change(Vote, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Vote cast successfully')
        expect(json_response['vote']['user_id']).to eq(user.id)
        expect(json_response['vote']['performer_id']).to eq(performer.id)
        expect(json_response['performer']['name']).to eq(performer.name)
        expect(json_response['performer']['vote_count']).to eq(1)
        expect(json_response['user']['has_voted']).to be true
        expect(json_response['user']['voted_performer']).to eq(performer.name)
      end
    end

    context 'when user has already voted' do
      let!(:another_performer) { create(:performer, name: 'Another Performer') }
      let(:valid_params) do
        {
          vote: {
            performer_id: another_performer.id
          }
        }
      end

      before do
        user.vote_for(performer) # User votes for first performer
      end

      it 'does not create vote and returns error' do
        expect {
          post '/votes', params: valid_params, headers: headers, as: :json
        }.not_to change(Vote, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('User has already voted')
      end
    end

    context 'with non-existent performer ID' do
      let(:invalid_params) do
        {
          vote: {
            performer_id: 999999
          }
        }
      end

      it 'returns performer not found error' do
        expect {
          post '/votes', params: invalid_params, headers: headers, as: :json
        }.not_to change(Vote, :count)

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Performer not found')
      end
    end



    context 'without authentication' do
      let(:valid_params) do
        {
          vote: {
            performer_id: performer.id
          }
        }
      end

      it 'returns unauthorized error' do
        post '/votes', params: valid_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid JWT token' do
      let(:invalid_headers) { { 'Authorization' => "Bearer invalid_token" } }
      let(:valid_params) do
        {
          vote: {
            performer_id: performer.id
          }
        }
      end

      it 'returns unauthorized error' do
        post '/votes', params: valid_params, headers: invalid_headers, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end
end
