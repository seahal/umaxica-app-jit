module Api
  module App
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
