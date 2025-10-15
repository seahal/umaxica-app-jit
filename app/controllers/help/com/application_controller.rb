# frozen_string_literal: true

module Help
  module Com
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
      include ::RateLimit
      include ::DefaultUrlOptions
    end
  end
end
