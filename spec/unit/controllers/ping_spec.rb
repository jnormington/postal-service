# frozen_string_literal: true

RSpec.describe PingController do
  include Rack::Test::Methods

  let(:app) { PingController }

  describe '/ping' do
    it 'returns PONG with 200 response' do
      get '/ping'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('PONG')
    end
  end
end
