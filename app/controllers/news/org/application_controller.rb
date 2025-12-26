# frozen_string_literal: true

module News
  module Org
    class ApplicationController < ActionController::Base
      include ::DefaultUrlOptions

      protect_from_forgery with: :exception
      include ::RateLimit

      protect_from_forgery with: :exception
      allow_browser versions: :modern
    end
  end
end
