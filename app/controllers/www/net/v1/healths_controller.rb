# frozen_string_literal: true

module Net
  module V1
    class HealthsController < ApplicationController
      include ::V1::Health
    end
  end
end
