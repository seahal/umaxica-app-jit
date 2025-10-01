# frozen_string_literal: true

module Api
  module App
    class ApplicationController < ActionController::API
      include ::RateLimit
    end
  end
end
