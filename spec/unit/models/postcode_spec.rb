# frozen_string_literal: true

RSpec.describe Postcode do
  subject { Postcode }

  describe '#initialize' do
    let(:postcode) { subject.new('s H 2 4 1ab ') }

    context 'postcode format' do
      it 'removes spaces and upper cases' do
        expect(postcode.value).to eq 'SH241AB'
      end
    end
  end

  describe '#valid?' do
    context 'when invalid postcode' do
      let(:postcode) { subject.new('sH24!ab ') }

      it 'returns false' do
        expect(postcode.valid?).to eq false
      end
    end

    context 'when empty postcode' do
      let(:postcode) { subject.new(' ') }

      it 'returns false' do
        expect(postcode.valid?).to eq false
      end
    end

    context 'when valid postcode' do
      let(:postcode) { subject.new('sH241 a b') }

      it 'returns true' do
        expect(postcode.valid?).to be_truthy
      end
    end
  end
end
