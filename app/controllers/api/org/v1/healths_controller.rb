module Api
  module Org
    module V1
      class HealthsController < ApplicationController
        include ::V1::Health
      end
    end
  end
end
