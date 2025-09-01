# frozen_string_literal: true

module Apex
  module App
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
