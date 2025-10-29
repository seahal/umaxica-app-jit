# frozen_string_literal: true

module Apex
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::DefaultUrlOptions
      include ::Apex::Concerns::Regionalization

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone
    end
  end
end
