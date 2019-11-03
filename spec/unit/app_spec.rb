# frozen_string_literal: true

RSpec.describe PostcodeService do
  include ConfigHelper

  let(:config) { Config.new }

  describe '#initialize' do
    describe 'config loader' do
      it 'calls config load_and_validate' do
        expect_any_instance_of(Config).to receive(:load_and_validate).and_return(config)
        PostcodeService.new
      end

      it 'calls config load_and_validate with custom file' do
        expect_any_instance_of(Config).to receive(:load_and_validate).with('config.test').and_return(config)
        PostcodeService.new('config.test')
      end

      it 'calls BaseController to set config' do
        allow_any_instance_of(Config).to receive(:load_and_validate).and_return(config)
        expect(BaseController).to receive(:config=).with(config)
        PostcodeService.new
      end
    end
  end

  describe '#call' do
    let(:rack_app) { double(Rack::Builder) }

    before do
      allow_any_instance_of(Config).to receive(:load_and_validate)
    end

    it 'calls the app instance#call' do
      allow_any_instance_of(PostcodeService).to receive(:app).and_return(rack_app)
      expect(rack_app).to receive(:call).with('test').and_return(nil)

      PostcodeService.new.call('test')
    end
  end
end
