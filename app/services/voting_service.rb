class VotingService
  attr_reader :errors

  def initialize(user:)
    @user = user
    @errors = []
  end

  def call(performer:)
    return failure('User not found') unless @user
    return failure('User has already voted') if user_has_voted?
    return failure('Performer not found') unless performer

    vote_result = @user.vote_for(performer)

    if vote_result
      success(vote_result)
    else
      failure('Failed to cast vote')
    end
  end

  def success?
    @success == true
  end

  def failure?
    !success?
  end

  def result
    @vote
  end

  private

  def user_has_voted?
    @user.has_voted?
  end

  def success(vote)
    @success = true
    @vote = vote
    self
  end

  def failure(message)
    @success = false
    @errors << message
    self
  end
end
