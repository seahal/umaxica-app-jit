# frozen_string_literal: true

module Docs
  module Com
    class HealthsController < ApplicationController
      include ::Health

      def show
        show_html
      end
    end
  end
end
