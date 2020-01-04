# frozen_string_literal: true

# Postcode takes a raw user postcode
# and sanitizes it for further processing
class Postcode
  attr_reader :value

  def initialize(postcode)
    @raw = postcode
    @value = clean_postcode
  end

  def valid?
    !value.empty? && alphanumeric_chars_only?
  end

  private

  def clean_postcode
    @raw.strip.gsub(/\s+/, '').upcase
  end

  def alphanumeric_chars_only?
    value.match(/[^a-zA-Z\d]/).nil?
  end
end
