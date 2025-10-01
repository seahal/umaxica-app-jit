# frozen_string_literal: true

module Apex
  module Net
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
