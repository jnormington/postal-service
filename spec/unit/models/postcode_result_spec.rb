# frozen_string_literal: true

RSpec.describe PostcodeResult do
  subject { PostcodeResult }

  describe '#initialize' do
    let(:lsoa) { 'Barking and Dagenham' }

    context 'when no error' do
      let(:postcode_result) { subject.new(lsoa) }

      it 'sets the lsoa' do
        expect(postcode_result.err).to be_nil
        expect(postcode_result.lsoa).to eq lsoa
      end
    end

    context 'when an error passed' do
      let(:error) { 'Im an error' }
      let(:postcode_result) { subject.new(lsoa, error) }

      it 'sets the error' do
        expect(postcode_result.err).to eq error
        expect(postcode_result.lsoa).to eq lsoa
      end
    end
  end

  describe '#==' do
    context 'when object type different' do
      it 'returns false' do
        expect(subject.new('string') == 'string').to eq false
      end
    end

    context 'when lsoa different' do
      let(:postcode) { subject.new('LSoA1') }
      let(:other) { subject.new('LSOA1') }

      it 'returns false' do
        expect(postcode == other).to eq false
      end
    end

    context 'when err different' do
      let(:postcode) { subject.new('LSOA1', 'err1') }
      let(:other) { subject.new('LSOA1', nil) }

      it 'returns false' do
        expect(postcode == other).to eq false
      end
    end

    context 'when supported_lsoa different' do
      let(:postcode) { subject.new('LSOA1', 'err1') }
      let(:other) { subject.new('LSOA1', 'err1') }

      it 'returns false' do
        postcode.supported_lsoa = true
        expect(postcode == other).to eq false
      end
    end

    context 'when attributes same' do
      let(:postcode) { subject.new('LSOA1', 'err1') }
      let(:other) { subject.new('LSOA1', 'err1') }

      it 'returns true' do
        expect(postcode == other).to eq true
      end
    end
  end
end
