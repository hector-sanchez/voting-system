require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires an email' do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it 'requires a unique email' do
      create(:user, email: 'test@example.com')
      subject.email = 'test@example.com'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("has already been taken")
    end

    it 'requires a valid email format' do
      subject.email = 'invalid_email'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("is invalid")
    end

    it 'requires a zipcode' do
      subject.zipcode = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:zipcode]).to include("can't be blank")
    end

    it 'validates zipcode format' do
      subject.zipcode = '1234'
      expect(subject).not_to be_valid
      expect(subject.errors[:zipcode]).to include("must be a valid US zipcode (e.g., 12345 or 12345-6789)")
    end

    it 'accepts valid 5-digit zipcode' do
      subject.zipcode = '12345'
      expect(subject).to be_valid
    end

    it 'accepts valid 9-digit zipcode' do
      subject.zipcode = '12345-6789'
      expect(subject).to be_valid
    end

    it 'requires a password' do
      subject.password = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).to include("can't be blank")
    end
  end

  describe 'callbacks' do
    it 'converts email to lowercase before saving' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, email: 'test@example.com', zipcode: '12345', password: 'password123', password_confirmation: 'password123') }

    describe '.authenticate_with_zipcode' do
      it 'returns user with valid credentials' do
        user # Force creation of the user
        authenticated_user = User.authenticate_with_zipcode('test@example.com', '12345', 'password123')
        expect(authenticated_user).to eq(user)
      end

      it 'returns nil with invalid email' do
        user
        authenticated_user = User.authenticate_with_zipcode('wrong@example.com', '12345', 'password123')
        expect(authenticated_user).to be_nil
      end

      it 'returns nil with invalid zipcode' do
        user
        authenticated_user = User.authenticate_with_zipcode('test@example.com', '54321', 'password123')
        expect(authenticated_user).to be_nil
      end

      it 'returns nil with invalid password' do
        user
        authenticated_user = User.authenticate_with_zipcode('test@example.com', '12345', 'wrongpassword')
        expect(authenticated_user).to be_nil
      end
    end
  end

  describe 'token management' do
    let(:user) { create(:user) }

    describe '#invalidate_tokens!' do
      it 'increments token_version' do
        original_version = user.token_version
        user.invalidate_tokens!
        expect(user.token_version).to eq(original_version + 1)
      end
    end

    describe '#token_valid?' do
      it 'returns true for current token_version' do
        expect(user.token_valid?(user.token_version)).to be true
      end

      it 'returns false for outdated token_version' do
        expect(user.token_valid?(user.token_version - 1)).to be false
      end
    end

    describe '#generate_token_payload' do
      it 'returns a hash with user information' do
        token_payload = user.generate_token_payload
        expect(token_payload).to include(
          user_id: user.id,
          email: user.email,
          zipcode: user.zipcode,
          token_version: user.token_version
        )
        expect(token_payload[:exp]).to be > Time.current.to_i
      end
    end
  end
  
  describe 'voting functionality' do
    let(:user) { create(:user) }
    let(:performer1) { create(:performer, name: 'The Beatles') }
    let(:performer2) { create(:performer, name: 'Queen') }

    describe '#vote_for' do
      it 'allows user to vote for a performer' do
        result = user.vote_for(performer1)
        expect(result).to be_truthy
        expect(user.has_voted?).to be true
        expect(user.voted_performer).to eq(performer1)
      end

      it 'prevents user from voting twice' do
        user.vote_for(performer1)
        result = user.vote_for(performer2)
        expect(result).to be false
        expect(user.voted_performer).to eq(performer1)
      end
    end

    describe '#has_voted?' do
      it 'returns true when user has voted' do
        user.vote_for(performer1)
        expect(user.has_voted?).to be true
      end

      it 'returns false when user has not voted' do
        expect(user.has_voted?).to be false
      end
    end
  end
end
