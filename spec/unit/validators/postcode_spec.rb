# frozen_string_literal: true

RSpec.describe PostcodeValidator do
  subject { PostcodeValidator }
  let(:postcode_config) do
    OpenStruct.new(
      overrides: %w[SH241AA SH241AB SH242AA],
      lsoa_whitelist: ['Lsoa and Ab', 'Lsoabc']
    )
  end

  describe '#initialize' do
    let(:validator) { subject.new('s H 2 4 1ab ') }

    describe 'postcode format' do
      it 'removes spaces and upper cases' do
        expect(validator.postcode).to eq 'SH241AB'
      end
    end
  end

  describe '#result' do
    describe 'invalid postcode' do
      it 'returns an error with whitespace' do
        expect(subject.new(' ').result).to eq(
          subject::Result.new(ErrorCodes::POSTCODE_NOT_VALID)
        )
      end

      it 'returns an error with non-alphanumeric characters' do
        expect(subject.new('SH24 !AA').result).to eq(
          subject::Result.new(ErrorCodes::POSTCODE_NOT_VALID)
        )
      end
    end

    describe 'overridden postcode' do
      it 'returns SH24 1AB as supported LSOA' do
        expect(subject.new('SH24 1ab', postcode_config).result).to eq(
          subject::Result.new(nil, true, 'SH24')
        )
      end
    end

    describe 'query LSOA of postcode' do
      let(:in_postcode) { 'se1 7qd' }
      let(:postcode) { 'SE17QD' }

      subject { PostcodeValidator.new(in_postcode, postcode_config) }

      it 'returns unexpected error when 400 error' do
        expect(UkPostcodesIo).to receive(:lookup).with(postcode).and_return(
          OpenStruct.new(data: nil, status: 400)
        )

        expect(subject.result).to eq(
          PostcodeValidator::Result.new(ErrorCodes::UNEXPECTED_ERROR)
        )
      end

      it 'returns unexpected error when 500 error' do
        expect(UkPostcodesIo).to receive(:lookup).with(postcode).and_return(
          OpenStruct.new(data: nil, status: 500)
        )

        expect(subject.result).to eq(
          PostcodeValidator::Result.new(ErrorCodes::UNEXPECTED_ERROR)
        )
      end

      it 'returns postcode not found' do
        expect(UkPostcodesIo).to receive(:lookup).with('FA12AB').and_return(
          OpenStruct.new(data: nil, status: 404)
        )

        expect(PostcodeValidator.new('FA1 2AB', postcode_config).result).to eq(
          PostcodeValidator::Result.new(ErrorCodes::POSTCODE_NOT_FOUND)
        )
      end

      it 'returns postcode not in supported LSOA' do
        expect(UkPostcodesIo).to receive(:lookup).with(postcode).and_return(
          OpenStruct.new(
            data: OpenStruct.new(
              lsoa: 'Lsoac 034A'
            ),
            status: 200
          )
        )

        expect(subject.result).to eq(
          PostcodeValidator::Result.new(nil, false, 'Lsoac 034A')
        )
      end

      it 'returns postcode is supported when LSOA one word' do
        expect(UkPostcodesIo).to receive(:lookup).with(postcode).and_return(
          OpenStruct.new(
            data: OpenStruct.new(
              lsoa: 'Lsoabc 034A'
            ),
            status: 200
          )
        )

        expect(subject.result).to eq(
          PostcodeValidator::Result.new(nil, true, 'Lsoabc 034A')
        )
      end

      it 'returns postcode is supported when LSOA multiple words' do
        expect(UkPostcodesIo).to receive(:lookup).with(postcode).and_return(
          OpenStruct.new(
            data: OpenStruct.new(
              lsoa: 'Lsoa and Ab 034A'
            ),
            status: 200
          )
        )

        expect(subject.result).to eq(
          PostcodeValidator::Result.new(nil, true, 'Lsoa and Ab 034A')
        )
      end
    end
  end
end
