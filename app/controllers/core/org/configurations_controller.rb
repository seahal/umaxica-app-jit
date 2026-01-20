# frozen_string_literal: true

module Core
  module Org
    class ConfigurationsController < Core::Org::ApplicationController
      prepend_before_action :authenticate_staff!

      def show
      end
    end
  end
end
