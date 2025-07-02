class HomeController < ApplicationController
  def index
    if authenticated_user
      # If user is authenticated, redirect to voting results
      redirect_to voting_results_path
    else
      # If user is not authenticated, redirect to sign in
      redirect_to sign_in_path
    end
  end

  private

  def authenticated_user
    token = extract_token_from_header
    return nil unless token

    decoded_token = decode_token(token)
    return nil unless decoded_token

    user = User.find_by(id: decoded_token['user_id'])
    return nil unless user

    # Check if token is still valid (not invalidated)
    return nil unless user.token_valid?(decoded_token['token_version'])

    user
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    # Expecting format: "Bearer <token>"
    token = auth_header.split(' ').last
    token if auth_header.start_with?('Bearer ')
  end

  def decode_token(token)
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
