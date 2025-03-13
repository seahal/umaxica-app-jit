# frozen_string_literal: true

module Www
  module App
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
