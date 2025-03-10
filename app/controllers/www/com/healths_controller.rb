# frozen_string_literal: true

module Www
  module Com
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
