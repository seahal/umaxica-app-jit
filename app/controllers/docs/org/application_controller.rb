# frozen_string_literal: true

module Docs
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::DefaultUrlOptions
      allow_browser versions: :modern
    end
  end
end
