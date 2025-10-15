# frozen_string_literal: true

module News
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::DefaultUrlOptions
      allow_browser versions: :modern
    end
  end
end
