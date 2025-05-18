# frozen_string_literal: true

module Docs
  module Org
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
