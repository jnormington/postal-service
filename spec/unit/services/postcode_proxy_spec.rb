# frozen_string_literal: true

RSpec.describe PostcodeProxy do
  let(:postcode) { Postcode.new('sh24 1ab') }
  let(:config) do
    OpenStruct.new(
      overrides: %w[SH241AA SH241AB SH242AA],
      lsoa_whitelist: ['Lsoa and Ab', 'Lsoabc']
    )
  end

  subject { PostcodeProxy }

  describe '#query' do
    let(:service) { PostcodesIOService.new(postcode) }

    context 'invalid postcode' do
      let(:postcode) { Postcode.new('sh23!a') }

      it 'returns an error result' do
        expect(subject.new(service, config).query).to eq(
          PostcodeResult.new(nil, ErrorCodes::POSTCODE_NOT_VALID)
        )
      end
    end

    describe 'overridden postcode' do
      let(:result) do
        result = PostcodeResult.new('SH24')
        result.supported_lsoa = true
        result
      end

      it 'returns SH24 1AB as supported LSOA' do
        expect(subject.new(service, config).query).to eq result
      end
    end

    context 'querying LSOA postcode service' do
      let(:postcode) { Postcode.new('se1 7qd') }

      subject { PostcodeProxy.new(service, config) }

      it 'returns error result' do
        expect(UkPostcodesIo).to receive(:lookup).with(postcode.value).and_return(
          OpenStruct.new(data: nil, status: 400)
        )

        expect(subject.query).to eq(PostcodeResult.new(nil, ErrorCodes::UNEXPECTED_ERROR))
      end

      context 'when not supported' do
        let(:result) do
          result = PostcodeResult.new('Lsoac 034A')
          result.supported_lsoa = false
          result
        end

        it 'returns postcode not in supported LSOA' do
          expect(UkPostcodesIo).to receive(:lookup).with(postcode.value).and_return(
            OpenStruct.new(
              data: OpenStruct.new(
                lsoa: 'Lsoac 034A'
              ),
              status: 200
            )
          )

          expect(subject.query).to eq result
        end
      end

      context 'when LSOA one word' do
        let(:lsoa) { 'Lsoabc 034A' }

        let(:result) do
          result = PostcodeResult.new(lsoa)
          result.supported_lsoa = true
          result
        end

        it 'returns postcode is supported' do
          expect(UkPostcodesIo).to receive(:lookup).with(postcode.value).and_return(
            OpenStruct.new(data: OpenStruct.new(lsoa: lsoa), status: 200)
          )

          expect(subject.query).to eq result
        end
      end

      context 'when LSOA multiple words' do
        let(:lsoa) { 'Lsoa and Ab 034A' }

        let(:result) do
          result = PostcodeResult.new(lsoa)
          result.supported_lsoa = true
          result
        end

        it 'returns postcode is supported' do
          expect(UkPostcodesIo).to receive(:lookup).with(postcode.value).and_return(
            OpenStruct.new(data: OpenStruct.new(lsoa: lsoa), status: 200)
          )

          expect(subject.query).to eq result
        end
      end
    end
  end
end
