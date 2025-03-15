
module Api
  module App
    module V1
      class HealthsController < ApplicationController
        include ::V1::Health
      end
    end
  end
end
