# frozen_string_literal: true

# PingController is the healthcheck controller
# for the postal service
class PingController < BaseController
  get '/ping' do
    'PONG'
  end
end
