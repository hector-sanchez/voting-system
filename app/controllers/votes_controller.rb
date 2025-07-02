class VotesController < ApplicationController
  include Authentication

  # Skip authentication for HTML requests to the voting page (React will handle auth)
  # But the issue is that when the browser navigates to /vote,
  # it's making a regular HTML request, not an AJAX request with the
  # Authorization header.
  # The Rails controller is trying to authenticate the HTML request,
  # but there's no way for the browser to automatically include the
  # JWT token in a regular page navigation.
  skip_before_action :authenticate_user, only: [:new]

  # GET /vote (voting page)
  def new
    # Render the voting form
    # Authentication will be handled by the React component
  end

  # POST /votes
  def create
    # Get the authenticated user from the JWT token
    user = current_user

    # Get performer_id from vote parameters
    performer_id = vote_params[:performer_id]
    return render json: { error: 'Performer ID is required' }, status: :bad_request if performer_id.blank?

    # Find the performer by ID
    performer = Performer.find_by(id: performer_id)
    return render json: { error: 'Performer not found' }, status: :not_found unless performer

    # Use the voting service to cast the vote
    voting_service = VotingService.new(user: user)
    voting_result = voting_service.call(performer: performer)

    if voting_result.success?
      render json: {
        message: 'Vote cast successfully',
        vote: {
          id: voting_result.result.id,
          user_id: voting_result.result.user_id,
          performer_id: voting_result.result.performer_id
        },
        performer: {
          id: performer.id,
          name: performer.name,
          vote_count: performer.vote_count
        },
        user: {
          id: user.id,
          email: user.email,
          has_voted: user.has_voted?,
          voted_performer: user.voted_performer.name
        }
      }, status: :created
    else
      render json: {
        error: voting_service.errors.first
      }, status: :unprocessable_entity
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:performer_id)
  end
end
