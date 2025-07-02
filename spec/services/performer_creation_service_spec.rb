require 'rails_helper'

RSpec.describe PerformerCreationService, type: :service do
  describe '#call' do
    subject { described_class.new.call(name: name) }

    context 'with valid name' do
      let(:name) { 'Test Performer' }

      it 'creates a performer successfully' do
        expect { subject }.to change(Performer, :count).by(1)
        expect(subject.success?).to be true
        expect(subject.result).to be_a(Performer)
        expect(subject.result.name).to eq('Test Performer')
      end
    end

    context 'with blank name' do
      let(:name) { '' }

      it 'fails with appropriate error' do
        expect { subject }.not_to change(Performer, :count)
        expect(subject.failure?).to be true
        expect(subject.errors).to include('Performer name is required')
      end
    end

    context 'with nil name' do
      let(:name) { nil }

      it 'fails with appropriate error' do
        expect { subject }.not_to change(Performer, :count)
        expect(subject.failure?).to be true
        expect(subject.errors).to include('Performer name is required')
      end
    end

    context 'when maximum performers limit is reached' do
      let(:name) { 'Test Performer' }

      before do
        create_list(:performer, 10)
      end

      it 'fails with maximum limit error' do
        expect { subject }.not_to change(Performer, :count)
        expect(subject.failure?).to be true
        expect(subject.errors).to include('Maximum number of performers (10) reached')
      end
    end

    context 'with invalid performer attributes' do
      let(:name) { 'a' * 256 } # Exceeds maximum length

      it 'fails with validation errors' do
        expect { subject }.not_to change(Performer, :count)
        expect(subject.failure?).to be true
        expect(subject.errors).to include('Failed to create performer')
      end
    end
  end
end
