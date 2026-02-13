# frozen_string_literal: true

module Apex
  module Org
    class ConfigurationsController < ApplicationController
      prepend_before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

      def show
        # Render configuration overview
      end
    end
  end
end
