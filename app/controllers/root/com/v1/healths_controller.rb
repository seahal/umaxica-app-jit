# frozen_string_literal: true

module Root
  module Com
    module V1
      class HealthsController < ApplicationController
        include ::Health

        def show
          show_json
        end
      end
    end
  end
end
