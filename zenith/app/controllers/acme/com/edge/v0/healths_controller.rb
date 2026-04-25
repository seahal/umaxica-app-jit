# typed: false
# frozen_string_literal: true

module Acme
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
