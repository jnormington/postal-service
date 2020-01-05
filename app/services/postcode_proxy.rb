# frozen_string_literal: true

# PostcodeProxy takes a service and config instance checking
# the postcode validility and if its whitelisted and or an
# overridden postcode before proxying to the service
class PostcodeProxy
  def initialize(service, config)
    @service = service
    @config = config
  end

  def query
    unless postcode.valid?
      return PostcodeResult.new(nil, ErrorCodes::POSTCODE_NOT_VALID)
    end

    if overridden_postcode?
      result = PostcodeResult.new('SH24')
      result.supported_lsoa = true

      return result
    end

    result = @service.query
    return result if result.err

    result.supported_lsoa = lsoa_whitelisted?(result.lsoa)
    result
  end

  private

  attr_reader :service, :config

  def lsoa_whitelisted?(user_lsoa)
    config.lsoa_whitelist.each do |lsoa|
      return true if user_lsoa.start_with? lsoa
    end

    false
  end

  def overridden_postcode?
    config.overrides.include? postcode.value
  end

  def postcode
    service.postcode
  end
end
