# frozen_string_literal: true

require 'sinatra/base'
require 'uk_postcodes_io'

require './app/config'
require './app/helpers/error_handler'
require './app/helpers/error_codes'
require './app/validators/postcode'

require './app/controllers/base'
require './app/controllers/ping'

# PostcodeService is the entry point for the service
class PostcodeService
  attr_reader :app

  def initialize
    BaseController.config = Config.new.load_and_validate

    @app = Rack::Builder.app do
      run BaseController
      run PingController
    end
  end

  def call(env)
    app.call(env)
  end
end
