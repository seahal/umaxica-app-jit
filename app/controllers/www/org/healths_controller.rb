# frozen_string_literal: true

module Www
  module Org
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
