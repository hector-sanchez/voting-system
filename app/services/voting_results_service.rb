class VotingResultsService
  def self.get_all_with_counts
    performer_vote_counts = Vote.group(:performer_id).count

    Performer.all.map do |performer|
      vote_count = performer_vote_counts[performer.id] || 0
      # Add vote_count as an attribute
      performer.define_singleton_method(:vote_count) { vote_count }
      performer
    end.sort_by { |p| [-p.vote_count, p.name] }
  end
end
