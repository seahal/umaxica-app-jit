# frozen_string_literal: true

module Bff
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
