# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Client
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
