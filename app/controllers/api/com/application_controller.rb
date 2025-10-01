# frozen_string_literal: true

module Api
  module Com
    class ApplicationController < ActionController::API
      include ::RateLimit
    end
  end
end
