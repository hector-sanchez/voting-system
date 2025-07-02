class PerformersController < ApplicationController
  include Authentication

  # POST /performers
  def create
    # Use the authenticated user from the token
    user = current_user

    # Create the performer using the service
    creation_service = PerformerCreationService.new
    creation_result = creation_service.call(name: performer_params[:name])

    if creation_result.failure?
      return render json: {
        error: creation_service.errors.first,
        details: creation_service.errors[1..-1] || []
      }, status: :unprocessable_entity
    end

    performer = creation_result.result

    # Vote for the performer using the voting service
    voting_service = VotingService.new(user: user)
    voting_result = voting_service.call(performer: performer)

    if voting_result.failure?
      # If voting failed, clean up the performer
      performer.destroy
      return render json: {
        error: voting_service.errors.first
      }, status: :unprocessable_entity
    end

    # Return success response
    render json: {
      message: 'Performer created and voted for successfully',
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
  end

  private

  def performer_params
    params.require(:performer).permit(:name)
  end
end
