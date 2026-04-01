# typed: false
# frozen_string_literal: true

module Core
  module App
    class HealthsController < ApplicationController
      include ::Health

      def show
        show_plain_text
      end
    end
  end
end
