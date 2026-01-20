# frozen_string_literal: true

module Core
  module Com
    class ConfigurationsController < Core::Com::ApplicationController
      prepend_before_action :authenticate_user!

      def show
      end
    end
  end
end
