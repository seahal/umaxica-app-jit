# frozen_string_literal: true

module Mews
  module App
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
