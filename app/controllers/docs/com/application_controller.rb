# frozen_string_literal: true

module Docs
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit

      protect_from_forgery with: :exception
      include ::DefaultUrlOptions

      protect_from_forgery with: :exception
      allow_browser versions: :modern
    end
  end
end
