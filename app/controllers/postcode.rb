# frozen_string_literal: true

# PostcodeController validates the users postcode and
# returns a response to whether its supported by our service
class PostcodeController < BaseController
  include ErrorCodes
  include ErrorHandler

  get '/:postcode' do
    validator = PostcodeValidator.new(
      params[:postcode],
      self.class.config.postcode_opts
    )

    result = validator.result

    case result.err
    when POSTCODE_NOT_VALID
      halt_with_error(400, result.err, 'postcode not valid')
    when POSTCODE_NOT_FOUND
      halt_with_error(404, result.err, 'postcode not found')
    when UNEXPECTED_ERROR
      halt_with_error(500, result.err, 'postcode lookup failure')
    end

    json result: { supported_lsoa: result.supported_lsoa, lsoa: result.lsoa }
  end
end
