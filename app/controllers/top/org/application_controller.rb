# frozen_string_literal: true

module Top
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::DefaultUrlOptions
      include ::Top::Concerns::Regionalization

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone
    end
  end
end
