# frozen_string_literal: true

module Help
  module App
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
