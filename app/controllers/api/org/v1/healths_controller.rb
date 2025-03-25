module Api
  module Org
    module V1
      class HealthsController < ApplicationController
        include ::Health
      end
    end
  end
end
