require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'POST /sessions' do
    let!(:user) { create(:user, email: 'test@example.com', zipcode: '12345', password: 'password123') }

    context 'with valid credentials' do
      let(:valid_params) do
        {
          session: {
            email: 'test@example.com',
            zipcode: '12345',
            password: 'password123'
          }
        }
      end

      it 'returns a success response with token and user data' do
        post '/sessions', params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Login successful')
        expect(json_response['token']).to be_present
        expect(json_response['user']['id']).to eq(user.id)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['user']['zipcode']).to eq(user.zipcode)
      end
    end

    context 'with invalid credentials' do
      let(:invalid_params) do
        {
          session: {
            email: 'test@example.com',
            zipcode: '12345',
            password: 'wrong_password'
          }
        }
      end

      it 'returns an unauthorized response' do
        post '/sessions', params: invalid_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Invalid email, zipcode, or password')
      end
    end

    context 'with missing parameters' do
      let(:missing_params) do
        {
          session: {
            email: 'test@example.com'
            # missing zipcode and password
          }
        }
      end

      it 'returns an unauthorized response' do
        post '/sessions', params: missing_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Invalid email, zipcode, or password')
      end
    end
  end

  describe 'DELETE /sessions' do
    let!(:user) { create(:user) }
    let(:token) { JWT.encode(user.generate_token_payload, Rails.application.secret_key_base, 'HS256') }

    context 'when logged in' do
      it 'invalidates tokens and returns success' do
        delete '/sessions', headers: { 'Authorization' => "Bearer #{token}" }, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Logout successful')

        # Verify token version was incremented
        user.reload
        expect(user.token_version).to eq(1)
      end
    end

    context 'when not logged in' do
      it 'returns unauthorized response' do
        delete '/sessions', as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end
end
