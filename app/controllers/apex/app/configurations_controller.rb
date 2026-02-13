# frozen_string_literal: true

module Apex
  module App
    class ConfigurationsController < ApplicationController
      auth_required!
      prepend_before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

      def show
        # Configuration display
      end
    end
  end
end
