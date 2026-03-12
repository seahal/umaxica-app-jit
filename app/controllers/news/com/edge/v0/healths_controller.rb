# typed: false
# frozen_string_literal: true

module News
  module Com
    module Edge
      module V0
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
