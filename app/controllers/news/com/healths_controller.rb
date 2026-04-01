# typed: false
# frozen_string_literal: true

module News
  module Com
    class HealthsController < ApplicationController
      include ::Health

      def show
        show_plain_text
      end
    end
  end
end
