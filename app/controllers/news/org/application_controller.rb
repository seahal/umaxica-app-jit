# frozen_string_literal: true

module News
  module Org
    class ApplicationController < ActionController::Base
      include ::DefaultUrlOptions
      include ::RateLimit
      allow_browser versions: :modern
    end
  end
end
