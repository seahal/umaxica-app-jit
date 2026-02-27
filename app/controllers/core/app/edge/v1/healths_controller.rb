# typed: false
# frozen_string_literal: true

module Core
  module App
    module Edge
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
end
