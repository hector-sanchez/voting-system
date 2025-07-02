class Performer < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  
  # Ensure name is stored with proper formatting
  before_save { self.name = name.strip }
end
