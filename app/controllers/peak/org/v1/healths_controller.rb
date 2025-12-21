# frozen_string_literal: true

module Peak
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
