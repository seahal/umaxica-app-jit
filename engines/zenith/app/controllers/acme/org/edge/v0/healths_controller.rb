# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    module Acme
      module Org
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
  end
end
