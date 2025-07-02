require 'rails_helper'

RSpec.describe VotingResultsService, type: :service do
  describe '.get_all_with_counts' do
    before do
      # Create test performers
      @performer1 = create(:performer, name: 'Alpha Band')
      @performer2 = create(:performer, name: 'Beta Group')
      @performer3 = create(:performer, name: 'Gamma Artists')

      # Create users and votes
      @user1 = create(:user, email: 'user1@test.com')
      @user2 = create(:user, email: 'user2@test.com')
      @user3 = create(:user, email: 'user3@test.com')

      # Create votes: performer1 gets 2 votes, performer2 gets 1 vote, performer3 gets 0 votes
      create(:vote, user: @user1, performer: @performer1)
      create(:vote, user: @user2, performer: @performer1)
      create(:vote, user: @user3, performer: @performer2)
    end

    it 'returns all performers with their vote counts' do
      results = VotingResultsService.get_all_with_counts

      expect(results).to be_an(Array)
      expect(results.length).to eq(3)

      # Check that results are sorted by vote count (descending) then by name (ascending)
      expect(results[0].name).to eq('Alpha Band')
      expect(results[0].vote_count).to eq(2)

      expect(results[1].name).to eq('Beta Group')
      expect(results[1].vote_count).to eq(1)

      expect(results[2].name).to eq('Gamma Artists')
      expect(results[2].vote_count).to eq(0)
    end

    it 'returns performers sorted by vote count descending, then name ascending' do
      # Create another performer with same vote count as performer2 to test name sorting
      performer4 = create(:performer, name: 'Alpha Zulu') # Should come before Beta Group alphabetically
      user4 = create(:user, email: 'user4@test.com')
      create(:vote, user: user4, performer: performer4)

      results = VotingResultsService.get_all_with_counts

      expect(results.length).to eq(4)

      # Alpha Band should be first (2 votes)
      expect(results[0].name).to eq('Alpha Band')
      expect(results[0].vote_count).to eq(2)

      # Alpha Zulu should come before Beta Group (both have 1 vote, sorted by name)
      expect(results[1].name).to eq('Alpha Zulu')
      expect(results[1].vote_count).to eq(1)

      expect(results[2].name).to eq('Beta Group')
      expect(results[2].vote_count).to eq(1)

      expect(results[3].name).to eq('Gamma Artists')
      expect(results[3].vote_count).to eq(0)
    end

    it 'handles empty votes gracefully' do
      Vote.destroy_all

      results = VotingResultsService.get_all_with_counts

      expect(results).to be_an(Array)
      expect(results.length).to eq(3)

      results.each do |performer|
        expect(performer.vote_count).to eq(0)
      end

      # Should still be sorted by name when all have 0 votes
      expect(results[0].name).to eq('Alpha Band')
      expect(results[1].name).to eq('Beta Group')
      expect(results[2].name).to eq('Gamma Artists')
    end

    it 'adds vote_count method to performer objects' do
      results = VotingResultsService.get_all_with_counts

      results.each do |performer|
        expect(performer).to respond_to(:vote_count)
        expect(performer.vote_count).to be_a(Integer)
        expect(performer.vote_count).to be >= 0
      end
    end
  end
end
