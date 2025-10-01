# frozen_string_literal: true

module Docs
  module Org
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern
      include ::RateLimit
    end
  end
end
