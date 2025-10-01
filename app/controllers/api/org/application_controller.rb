# frozen_string_literal: true

module Api
  module Org
    class ApplicationController < ActionController::API
      include ::RateLimit
    end
  end
end
