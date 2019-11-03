# frozen_string_literal: true

require 'sinatra/base'

require './app/controllers/base'
require './app/controllers/ping'

# PostcodeService is the entry point for the service
class PostcodeService
  attr_reader :app

  def initialize
    @app = Rack::Builder.app do
      run BaseController
      run PingController
    end
  end

  def call(env)
    app.call(env)
  end
end
