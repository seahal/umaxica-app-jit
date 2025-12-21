# frozen_string_literal: true

module Core
  module App
    class HealthsController < ApplicationController
      include ::Health

      def show
        show_html
      end
    end
  end
end
