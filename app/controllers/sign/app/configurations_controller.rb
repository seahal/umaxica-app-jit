# frozen_string_literal: true

module Sign
  module App
    class ConfigurationsController < ApplicationController
      before_action :authenticate_user!

      def show
      end
    end
  end
end
