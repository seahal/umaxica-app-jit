# frozen_string_literal: true

module Docs
  module Com
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
