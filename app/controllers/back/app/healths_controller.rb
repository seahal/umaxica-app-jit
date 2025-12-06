# frozen_string_literal: true

module Back
  module App
    class HealthsController < ApplicationController
      include ::Health

      def show
        show_html
      end
    end
  end
end
