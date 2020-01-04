# frozen_string_literal: true

# PostcodeResult contains the general
# result generated from a service
class PostcodeResult
  attr_reader :lsoa
  attr_accessor :err, :supported_lsoa

  def initialize(lsoa, err = nil)
    @lsoa = lsoa
    @err = err
  end
end
