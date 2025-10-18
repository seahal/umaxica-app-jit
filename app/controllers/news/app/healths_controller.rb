# frozen_string_literal: true

module News
  module App
    class HealthsController < ApplicationController
      include ::Health
      def show
        show_html
      end
    end
  end
end
