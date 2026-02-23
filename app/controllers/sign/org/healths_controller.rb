# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class HealthsController < ApplicationController
      public_strict!
      include ::Health

      def show
        show_html
      end
    end
  end
end
