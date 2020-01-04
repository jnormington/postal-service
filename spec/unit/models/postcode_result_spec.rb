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
end
