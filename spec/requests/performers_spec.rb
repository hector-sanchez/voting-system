require 'rails_helper'

RSpec.describe 'Performers', type: :request do
  describe 'POST /performers' do
    let!(:user) { create(:user) }
    let(:token) { JWT.encode(user.generate_token_payload, Rails.application.secret_key_base, 'HS256') }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    context 'with valid parameters and authenticated user' do
      let(:valid_params) do
        {
          performer: {
            name: 'New Performer'
          }
        }
      end

      it 'creates a new performer and votes for it' do
        expect {
          post '/performers', params: valid_params, headers: headers, as: :json
        }.to change(Performer, :count).by(1).and change(Vote, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Performer created and voted for successfully')
        expect(json_response['performer']['name']).to eq('New Performer')
        expect(json_response['performer']['vote_count']).to eq(1)
        expect(json_response['user']['has_voted']).to be true
        expect(json_response['user']['voted_performer']).to eq('New Performer')
      end
    end

    context 'when user has already voted' do
      let!(:existing_performer) { create(:performer) }
      let(:valid_params) do
        {
          performer: {
            name: 'Another Performer'
          }
        }
      end

      before do
        user.vote_for(existing_performer)
      end

      it 'does not create performer and returns error' do
        expect {
          post '/performers', params: valid_params, headers: headers, as: :json
        }.not_to change(Performer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('User has already voted')
      end
    end

    context 'when maximum performers limit is reached' do
      let(:valid_params) do
        {
          performer: {
            name: 'Overflow Performer'
          }
        }
      end

      before do
        # Create 10 performers to reach the limit
        create_list(:performer, 10)
      end

      it 'does not create performer and returns error' do
        expect {
          post '/performers', params: valid_params, headers: headers, as: :json
        }.not_to change(Performer, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Maximum number of performers (10) reached')
      end
    end
    context 'with invalid performer name' do
      let(:invalid_params) do
        {
          performer: {
            name: ''
          }
        }
      end

      it 'returns validation error' do
        post '/performers', params: invalid_params, headers: headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Performer name is required')
        expect(json_response['details']).to eq([])
      end
    end

    context 'without authentication' do
      let(:valid_params) do
        {
          performer: {
            name: 'New Performer',
            user_id: user.id
          }
        }
      end

      it 'returns unauthorized error' do
        post '/performers', params: valid_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end
end
