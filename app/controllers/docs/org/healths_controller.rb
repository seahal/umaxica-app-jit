module Docs
  module Org
    class HealthsController < ApplicationController
      include ::Health

      def show
        show_html
      end
    end
  end
end
