# frozen_string_literal: true

module Auth
  module App
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
