# frozen_string_literal: true

module Docs
  module App
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
