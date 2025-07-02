require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:performer) }
  end

  describe 'validations' do
    subject { build(:vote) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a user' do
      subject.user = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:user]).to include("can't be blank")
    end

    it 'requires a performer' do
      subject.performer = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:performer]).to include("can't be blank")
    end

    it 'ensures one vote per user' do
      user = create(:user)
      performer1 = create(:performer)
      performer2 = create(:performer)

      # First vote should be valid
      vote1 = create(:vote, user: user, performer: performer1)
      expect(vote1).to be_valid

      # Second vote by same user should be invalid
      vote2 = build(:vote, user: user, performer: performer2)
      expect(vote2).not_to be_valid
      expect(vote2.errors[:user_id]).to include("can only vote once")
    end
  end
end
