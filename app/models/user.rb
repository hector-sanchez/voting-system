class User < ApplicationRecord
  has_secure_password

  # Voting associations
  has_one :vote
  has_one :voted_performer, through: :vote, source: :performer

  # Validations
  validates :email, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :zipcode, presence: true,
                     format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid US zipcode (e.g., 12345 or 12345-6789)" }

  validates :token_version, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Ensure email is stored in lowercase
  before_save { self.email = email.downcase }

  # Custom authentication method that considers both email and zipcode
  def self.authenticate_with_zipcode(email, zipcode, password)
    user = find_by(email: email.downcase, zipcode: zipcode)
    return nil unless user

    user.authenticate(password) ? user : nil
  end

  # Method to invalidate all existing tokens by incrementing token_version
  def invalidate_tokens!
    increment!(:token_version)
  end

  # Method to generate a JWT token payload (implement JWT encoding separately)
  def generate_token_payload
    {
      user_id: id,
      email: email,
      zipcode: zipcode,
      token_version: token_version,
      exp: 24.hours.from_now.to_i
    }
  end

  # Method to check if a token is still valid
  def token_valid?(token_version_from_token)
    token_version == token_version_from_token
  end

  # Voting methods
  def vote_for(performer)
    return false if has_voted?

    self.create_vote(performer: performer)
  rescue ActiveRecord::RecordInvalid
    false
  end

  def has_voted?
    vote.present?
  end
end
