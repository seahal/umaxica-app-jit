# frozen_string_literal: true

module Sign
  module Org
    class HealthsController < ApplicationController
      include ::Health


      def show
        show_html
      end
    end
  end
end
