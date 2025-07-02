module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
  end

  private

  def authenticate_user
    token = extract_token_from_header
    return render_unauthorized unless token

    decoded_token = decode_token(token)
    return render_unauthorized unless decoded_token

    user = User.find_by(id: decoded_token['user_id'])
    return render_unauthorized unless user

    # Check if token is still valid (not invalidated)
    return render_unauthorized unless user.token_valid?(decoded_token['token_version'])

    @current_user = user    # List first 10 users with their login credentials
  end

  def current_user
    @current_user
  end

  def logged_in?
    !!current_user
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

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
