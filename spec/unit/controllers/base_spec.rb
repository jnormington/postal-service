# frozen_string_literal: true

RSpec.describe BaseController do
  include ConfigHelper

  describe '.config' do
    let(:config) { Config.new }

    it 'assigns config' do
      BaseController.config = config

      expect(BaseController.config).to eq config
    end
  end
end
