# frozen_string_literal: true

RSpec.describe Config do
  include ConfigHelper

  let(:config) { Config.new }

  def postcode_err(postcode)
    "invalid postcode format '#{postcode}' ensure all capitalized and no spaces"
  end

  describe '#load_and_validate' do
    describe 'when postcode config missing' do
      it 'raises an error' do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(JSON.generate({}))

        expect { config.load_and_validate }.to raise_error 'no postcode config'
      end
    end

    describe 'when postcode wrong format' do
      it 'raises an error when lowercased' do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(build_config_content(%w[SH241AA sh241ab]))

        expect { config.load_and_validate }.to raise_error postcode_err('sh241ab')
      end

      it 'raises an error when spaces' do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(build_config_content(['SH24 1AA', 'SH241AB']))

        expect { config.load_and_validate }.to raise_error postcode_err('SH24 1AA')
      end
    end

    describe 'when no lsoa whitelist' do
      let(:missing_lsoa) { 'no whitelisted lsoa' }

      it 'raises an error when no lsoa_whitelist config' do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(JSON.generate(postcode: {}))

        expect { config.load_and_validate }.to raise_error missing_lsoa
      end

      it 'raises an error when no items in lsoa_whitelist' do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(build_config_content(nil, []))

        expect { config.load_and_validate }.to raise_error missing_lsoa
      end
    end

    describe 'when lsoa whitelist exists' do
      it 'raises an error when blank string' do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(build_config_content(nil, ['LsoaB', '']))

        expect { config.load_and_validate }.to raise_error "invalid lsoa ''"
      end
    end

    describe 'when config valid' do
      before do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(build_config_content)
      end

      it 'raises no errors' do
        expect { config.load_and_validate }.not_to raise_error
      end

      it 'returns itself' do
        expect(config.load_and_validate).to eq config
      end
    end

    describe '#postcode_opts' do
      before do
        expect(File).to receive(:read)
          .with('config.json')
          .and_return(build_config_content)

        config.load_and_validate
      end

      it 'returns the postcode configuration' do
        expect(config.postcode_opts).to eq(
          JSON.parse(build_config_content, object_class: OpenStruct)['postcode']
        )
      end
    end
  end
end
