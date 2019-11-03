# frozen_string_literal: true

RSpec.describe PostcodeController do
  include Rack::Test::Methods

  let(:app) { PostcodeController }

  describe '/:postcode' do
    before do
      allow(BaseController).to receive(:config).and_return(
        OpenStruct.new(
          postcode_opts: OpenStruct.new(
            overrides: %w[SH241AB SH241AA],
            lsoa_whitelist: %w[Southwark Lambeth]
          )
        )
      )
    end

    describe 'invalid postcode' do
      it 'returns 400 with code with encoded space' do
        get '/%20'

        expect(last_response).to be_bad_request
        expect_content_type_and_cors_headers
        expect(JSON.parse(last_response.body)).to eq(
          'err' => ErrorCodes::POSTCODE_NOT_VALID,
          'message' => 'postcode not valid'
        )
      end

      it 'returns 400 with code with special character' do
        get '/F%21A2A'

        expect(last_response).to be_bad_request
        expect_content_type_and_cors_headers
        expect(JSON.parse(last_response.body)).to eq(
          'err' => ErrorCodes::POSTCODE_NOT_VALID,
          'message' => 'postcode not valid'
        )
      end
    end

    describe 'postcode not found' do
      before do
        allow(UkPostcodesIo).to receive(:lookup).and_return(
          OpenStruct.new(status: 404)
        )
      end

      it 'returns 404 with body' do
        get '/F00BAR'

        expect(last_response).to be_not_found
        expect_content_type_and_cors_headers

        expect(JSON.parse(last_response.body)).to eq(
          'err' => ErrorCodes::POSTCODE_NOT_FOUND,
          'message' => 'postcode not found'
        )
      end
    end

    describe 'unexpected error from postcodes.io' do
      before do
        allow(UkPostcodesIo).to receive(:lookup).and_return(
          OpenStruct.new(status: 500)
        )
      end

      it 'returns 500 with body' do
        get '/F00BAR'

        expect(last_response.status).to eq 500
        expect_content_type_and_cors_headers

        expect(JSON.parse(last_response.body)).to eq(
          'err' => ErrorCodes::UNEXPECTED_ERROR,
          'message' => 'postcode lookup failure'
        )
      end
    end

    describe 'postcode found not in LSOA' do
      before do
        allow(UkPostcodesIo).to receive(:lookup).and_return(
          OpenStruct.new(
            data: OpenStruct.new(
              lsoa: 'Barking and Dagenham 019E'
            ),
            status: 200
          )
        )
      end

      it 'returns 200 with body' do
        get '/F00BAR'

        expect(last_response).to be_ok
        expect_content_type_and_cors_headers

        expect(JSON.parse(last_response.body)).to eq(
          'result' => {
            'supported_lsoa' => false,
            'lsoa' => 'Barking and Dagenham 019E'
          }
        )
      end
    end

    describe 'postcode in LSOA' do
      before do
        allow(UkPostcodesIo).to receive(:lookup).and_return(
          OpenStruct.new(
            data: OpenStruct.new(
              lsoa: 'Lambeth 019E'
            ),
            status: 200
          )
        )
      end

      it 'returns 200 with body' do
        get '/F00BAR'

        expect(last_response).to be_ok
        expect_content_type_and_cors_headers

        expect(JSON.parse(last_response.body)).to eq(
          'result' => {
            'supported_lsoa' => true,
            'lsoa' => 'Lambeth 019E'
          }
        )
      end
    end
  end

  def expect_content_type_and_cors_headers
    expect(last_response.headers['Content-Type']).to eq 'application/json'
    expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
  end
end
