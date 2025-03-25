module Api
  module App
    module V1
      class HealthsController < ApplicationController
        include ::Health
      end
    end
  end
end
