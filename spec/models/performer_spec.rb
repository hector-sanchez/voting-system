require 'rails_helper'

RSpec.describe Performer, type: :model do
  describe 'validations' do
    subject { build(:performer) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'requires name to be at least 1 character' do
      subject.name = ""
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("is too short (minimum is 1 character)")
    end

    it 'requires name to be at most 255 characters' do
      subject.name = "a" * 256
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("is too long (maximum is 255 characters)")
    end
  end

  describe 'callbacks' do
    it 'strips whitespace from name before saving' do
      performer = build(:performer, name: "  Test Performer  ")
      performer.save!
      expect(performer.name).to eq("Test Performer")
    end
  end
end
