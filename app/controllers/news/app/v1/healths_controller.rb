# frozen_string_literal: true

module News
  module App
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
