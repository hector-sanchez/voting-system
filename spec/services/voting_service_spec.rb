require 'rails_helper'

RSpec.describe VotingService, type: :service do
  let(:user) { create(:user) }
  let(:performer) { create(:performer) }

  describe '#call' do
    subject { described_class.new(user: user).call(performer: performer) }

    context 'with valid user and performer' do
      it 'creates a vote successfully' do
        expect { subject }.to change(Vote, :count).by(1)
        expect(subject.success?).to be true
        expect(subject.result).to be_a(Vote)
        expect(user.voted_performer).to eq(performer)
      end
    end

    context 'when user has already voted' do
      let(:another_performer) { create(:performer, name: 'Another Performer') }

      before do
        user.vote_for(another_performer)
      end

      it 'fails with already voted error' do
        expect { subject }.not_to change(Vote, :count)
        expect(subject.failure?).to be true
        expect(subject.errors).to include('User has already voted')
      end
    end

    context 'with nil performer' do
      let(:performer) { nil }

      it 'fails with performer not found error' do
        expect { subject }.not_to change(Vote, :count)
        expect(subject.failure?).to be true
        expect(subject.errors).to include('Performer not found')
      end
    end
  end

  describe 'initialization with nil user' do
    subject { described_class.new(user: nil).call(performer: performer) }

    it 'fails with user not found error' do
      expect { subject }.not_to change(Vote, :count)
      expect(subject.failure?).to be true
      expect(subject.errors).to include('User not found')
    end
  end
end
