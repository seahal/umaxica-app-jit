# frozen_string_literal: true

module Core
  module App
    class ConfigurationsController < Core::App::ApplicationController
      prepend_before_action :authenticate_user!

      def show
      end
    end
  end
end
