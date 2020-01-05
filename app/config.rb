# frozen_string_literal: true

# Config loader and validator of the format of the inputs
class Config
  attr_reader :postcode_opts

  def load_and_validate(file = 'config.json')
    @config = JSON.parse(File.read(file), object_class: OpenStruct)
    @postcode_opts = @config.postcode

    raise 'no postcode config' unless @postcode_opts

    validate_postcode_overrides
    validate_postcode_lsoa

    self
  end

  private

  def validate_postcode_overrides
    Array(@postcode_opts.overrides).map do |postcode|
      clean_postcode = Postcode.new(postcode).value

      unless clean_postcode == postcode
        raise "invalid postcode format '#{postcode}' " \
              'ensure all capitalized and no spaces'
      end
    end
  end

  def validate_postcode_lsoa
    raise 'no whitelisted lsoa' if Array(@postcode_opts.lsoa_whitelist).empty?

    Array(@postcode_opts.lsoa_whitelist).map do |lsoa|
      raise "invalid lsoa '#{lsoa}'" if lsoa.strip.empty?
    end
  end
end
