# frozen_string_literal: true

# BaseController is the base for all other
# controllers to extend with common configuration
class BaseController < Sinatra::Base
  class << self
    def config=(config)
      @@config = config
    end

    def config
      @@config
    end
  end
end
