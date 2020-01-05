# frozen_string_literal: true

require 'uri'

RSpec.describe 'Postcode API' do
  include Rack::Test::Methods
  include WebMock::API

  let(:app) { PostcodeService.new('config.test') }
  let(:config_file) { 'config.test' }

  before do
    WebMock.enable!
    FileUtils.cp('config.json.example', config_file)
  end

  after do
    File.delete(config_file)
  end

  it 'returns as supported for override postcode in config' do
    get '/postcodes/SH24%201AA'

    expect(last_response).to be_ok
    expect(unmarshal_body).to eq(
      result: {
        supported_lsoa: true,
        lsoa: 'SH24'
      }
    )
  end

  it 'returns postcode not found' do
    VCR.use_cassette(vcr_path('postcode_not_found')) do
      get '/postcodes/ZX213XA'
    end

    expect(last_response).to be_not_found
    expect(unmarshal_body).to eq(
      err: 'ErrPostcodeNotFound',
      message: 'postcode not found'
    )
  end

  it 'returns postcode outside of supported LSOA' do
    VCR.use_cassette(vcr_path('postcode_outside_supported_lsoa')) do
      get '/postcodes/IG110FX'
    end

    expect(last_response).to be_ok
    expect(unmarshal_body).to eq(
      result: {
        supported_lsoa: false,
        lsoa: 'Barking and Dagenham 019E'
      }
    )
  end

  [
    { postcode: 'SE17QD', lsoa: 'Southwark 034A' },
    { postcode: 'SE17QA', lsoa: 'Lambeth 036B' }
  ].map do |spec|
    postcode = spec[:postcode]
    clean_postcode = Postcode.new(postcode).value

    it "returns as supported lsoa for postcode #{postcode}" do
      VCR.use_cassette(vcr_path("postcode_#{clean_postcode}_supported_lsoa")) do
        get "/postcodes/#{postcode}"
      end

      expect(last_response).to be_ok
      expect(unmarshal_body).to eq(
        result: {
          supported_lsoa: true,
          lsoa: spec[:lsoa]
        }
      )
    end
  end

  def vcr_path(file)
    "postcode_io/#{file}"
  end

  def unmarshal_body
    JSON.parse(last_response.body, symbolize_names: true)
  end
end
