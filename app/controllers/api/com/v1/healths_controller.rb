module Api
  module Com
    module V1
      class HealthsController < ApplicationController
        include ::Health
      end
    end
  end
end
