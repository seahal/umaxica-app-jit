# frozen_string_literal: true

module Root
  module Org
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
