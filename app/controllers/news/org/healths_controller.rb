# frozen_string_literal: true

module News
  module Org
    class HealthsController < ApplicationController
      include ::Health

      # skip_before_action :canonicalize_query_params, only: [ :show ]
      def show
        show_html
      end
    end
  end
end
