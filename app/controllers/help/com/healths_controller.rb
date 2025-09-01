# frozen_string_literal: true

module Help
  module Com
    class HealthsController < ApplicationController
      include ::Health
    end
  end
end
