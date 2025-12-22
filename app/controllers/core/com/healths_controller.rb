module Core
  module Com
    class HealthsController < ApplicationController
      include ::Health

      def show
        show_html
      end
    end
  end
end
