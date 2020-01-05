# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/contrib'
require 'uk_postcodes_io'

require './app/config'
require './app/helpers/error_handler'
require './app/helpers/error_codes'

require './app/models/postcode'
require './app/models/postcode_result'
require './app/services/postcodes_io_service'
require './app/services/postcode_proxy'

require './app/validators/postcode'

require './app/controllers/base'
require './app/controllers/ping'
require './app/controllers/postcode'

# PostcodeService is the entry point for the service
class PostcodeService
  attr_reader :app

  def initialize(config_file = 'config.json')
    BaseController.config = Config.new.load_and_validate(config_file)

    @app = Rack::Builder.app do
      run BaseController
      run PingController

      map('/postcodes') do
        run PostcodeController
      end
    end
  end

  def call(env)
    app.call(env)
  end
end
