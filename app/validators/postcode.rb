# frozen_string_literal: true

# PostcodeValidator is the sanitizer and validator
# querying if its within a supported LSOA
class PostcodeValidator
  include ErrorCodes

  attr_reader :postcode

  Result = Struct.new(:err, :supported_lsoa, :lsoa)

  def initialize(postcode, config = nil)
    @raw = postcode
    @config = config
    @postcode = clean_postcode
  end

  def result
    return Result.new(POSTCODE_NOT_VALID) unless valid_postcode?
    return Result.new(nil, true, 'SH24') if overridden_postcode?

    result = query_result

    case result.status
    when 200
      lsoa = result.data.lsoa
      return Result.new(nil, lsoa_whitelisted?(lsoa), lsoa)
    when 404
      return Result.new(POSTCODE_NOT_FOUND)
    end

    Result.new(UNEXPECTED_ERROR)
  end

  private

  def lsoa_whitelisted?(user_lsoa)
    @config.lsoa_whitelist.each do |lsoa|
      return true if user_lsoa.start_with? lsoa
    end

    false
  end

  def overridden_postcode?
    @config.overrides.include? @postcode
  end

  def valid_postcode?
    !@postcode.empty? && alphanumeric_chars_only?
  end

  def clean_postcode
    @raw.strip.gsub(/\s+/, '').upcase
  end

  def query_result
    @query_result ||= UkPostcodesIo.lookup(@postcode)
  end

  def alphanumeric_chars_only?
    postcode.match(/[^a-zA-Z\d]/).nil?
  end
end
