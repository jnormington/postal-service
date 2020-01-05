# frozen_string_literal: true

RSpec.describe PostcodesIOService do
  let(:postcode) { Postcode.new('s H 2 4 1ab ') }

  subject { PostcodesIOService }

  describe '#query' do
    context 'when it errors' do
      subject { PostcodesIOService.new(postcode) }

      it 'returns unexpected error when 400 error' do
        expect(UkPostcodesIo).to receive(:lookup)
          .with(postcode.value)
          .and_return(OpenStruct.new(data: nil, status: 400))

        expect(subject.query).to eq(
          PostcodeResult.new(nil, ErrorCodes::UNEXPECTED_ERROR)
        )
      end

      it 'returns unexpected error when 500 error' do
        expect(UkPostcodesIo).to receive(:lookup)
          .with(postcode.value)
          .and_return(OpenStruct.new(data: nil, status: 500))

        expect(subject.query).to eq(
          PostcodeResult.new(nil, ErrorCodes::UNEXPECTED_ERROR)
        )
      end

      it 'returns postcode not found' do
        expect(UkPostcodesIo).to receive(:lookup).with('FA12AB').and_return(
          OpenStruct.new(data: nil, status: 404)
        )

        expect(PostcodesIOService.new(Postcode.new('FA1 2AB')).query).to eq(
          PostcodeResult.new(nil, ErrorCodes::POSTCODE_NOT_FOUND)
        )
      end
    end

    it 'returns postcode result with LSOA' do
      expect(UkPostcodesIo).to receive(:lookup).with(postcode.value).and_return(
        OpenStruct.new(
          data: OpenStruct.new(
            lsoa: 'Lsoac 034A'
          ),
          status: 200
        )
      )

      expect(subject.new(postcode).query).to eq(PostcodeResult.new('Lsoac 034A'))
    end
  end
end
