class SessionsController < ApplicationController
  include Authentication

  # Skip authentication for both login and logout actions
  skip_before_action :authenticate_user, only: [:new, :create, :destroy]

  # GET /sign_in (sign in page)
  def new
    # Render the sign in form
  end

  # POST /sessions (login)
  def create
    user = User.authenticate_with_zipcode(
      session_params[:email],
      session_params[:zipcode],
      session_params[:password]
    )

    if user
      token = encode_token(user.generate_token_payload)

      render json: {
        message: 'Login successful',
        token: token,
        redirect_to: (user.vote.present? ? '/' : '/vote'), # Determine redirect path based on voting status
        user: {
          id: user.id,
          email: user.email,
          zipcode: user.zipcode,
          has_voted: user.vote.present?
        }
      }, status: :ok
    else
      render json: {
        error: 'Invalid email, zipcode, or password'
      }, status: :unauthorized
    end
  end

  # DELETE /sessions (logout)
  def destroy
    # Manually authenticate for logout
    token = extract_token_from_header
    if token
      decoded_token = decode_token(token)
      if decoded_token
        user = User.find_by(id: decoded_token['user_id'])
        if user && user.token_valid?(decoded_token['token_version'])
          # Invalidate all tokens for this user
          user.invalidate_tokens!
          render json: {
            message: 'Logout successful'
          }, status: :ok
          return
        end
      end
    end

    render json: {
      error: 'Unauthorized'
    }, status: :unauthorized
  end

  private

  def session_params
    params.require(:session).permit(:email, :zipcode, :password)
  end
end
