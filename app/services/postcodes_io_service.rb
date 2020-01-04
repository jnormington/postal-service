# frozen_string_literal: true

class PostcodesIOService
  include ErrorCodes

  attr_reader :postcode

  def initialize(postcode)
    @postcode = postcode
  end

  def query
    result = query_result

    case result.status
    when 200
      lsoa = result.data.lsoa
      return PostcodeResult.new(lsoa)
    when 404
      return PostcodeResult.new(nil, POSTCODE_NOT_FOUND)
    end

    PostcodeResult.new(nil, UNEXPECTED_ERROR)
  end

  private

  def query_result
    @query_result ||= UkPostcodesIo.lookup(@postcode.value)
  end
end
