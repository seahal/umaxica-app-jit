# frozen_string_literal: true

module Www
  module App
    class StagingsController < ApplicationController
      include ::Staging
    end
  end
end
