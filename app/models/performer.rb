class Performer < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }

  # Voting associations
  has_many :votes
  has_many :voters, through: :votes, source: :user

  # Ensure name is stored with proper formatting
  before_save { self.name = name.strip }

  # Get vote count for this performer
  def vote_count
    votes.count
  end
end
