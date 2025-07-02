class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :performer

  # Ensure one vote per user
  validates :user_id, uniqueness: { message: "can only vote once" }

  # Validate that user and performer exist
  validates :user, presence: true
  validates :performer, presence: true
end
