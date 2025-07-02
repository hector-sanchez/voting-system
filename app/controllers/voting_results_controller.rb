class VotingResultsController < ApplicationController
  # GET /voting_results
  def index
    voting_results = VotingResultsService.get_all_with_counts
    total_votes = voting_results.sum(&:vote_count)

    render json: {
      total_votes: total_votes,
      results: voting_results.map do |result|
        {
          performer: {
            id: result.id,
            name: result.name
          },
          vote_count: result.vote_count
        }
      end
    }
  end
end
